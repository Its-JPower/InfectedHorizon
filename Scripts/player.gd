extends CharacterBody2D


signal Shot

@onready var health_bar: TextureProgressBar = $UI/Control/Health
@export var acceleration : float = 40.0 # variable for acceleration
@export var friction = 50.0 # variable for friction
@export var scoped_speed_reduction : float = 15.0 # variable for scoped speed reduction
@export var stamina_regen_rate : float = 0.25 # lowest regen rate for stamina
@export var max_regen_rate : float = 3.0 # maximum regen rate for stamina
@export var stamina_depletion_rate : float = 5.0 # stamina decrease rate per second during sprinting
@onready var label = $UI/Control/Ammo
@onready var player = $"."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var anim_player = $AnimationPlayer
@onready var stamina_bar = $UI/Control/Stamina
@onready var camera = $Camera2D # Reference to the Camera2D node
var scoped : bool = false
var shooting : bool = false
var reloading : bool = false
var sprinting : bool = false
var direction = Vector2.ZERO
var can_use_stamina = true
@onready var world = $".."
@onready var shot_timer = $ShotCooldown
@onready var hotbar_buttons = []
const handgun_bullet = preload("res://Scenes/handgun_bullet.tscn")
const rifle_bullet = preload("res://Scenes/rifle_bullet.tscn")
const DAMAGE_INDICATOR = preload("res://Scenes/damage_indicator.tscn")
var rotation_speed = 7.5
var target_rotation = 0.0
@onready var die_menu: Control = $UI/Control/dieMenu
var current_ammo = 0
@onready var shop_button: TextureButton = $UI/Control/ShopButton


func _ready():
	PlayerStats.UpdateMaxHealth.connect(_on_max_health_update) # Connects health update signal from the PlayerStats Singleton
	PlayerStats.UpdateMaxStamina.connect(_on_max_stamina_update) # Connects stamina update signal from the PlayerStats Singleton
	stamina_bar.value = PlayerStats.stamina
	var grid_container = $UI/Control/Hotbar
	for button in grid_container.get_children():
		if button is Button:
			hotbar_buttons.append(button) #adds the hottbar buttons to an array
	hotbar_buttons.append(shop_button)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if not is_click_on_hotbar(event.position): # If the mouse input wasn't on the hotbar
				handle_shooting()

func is_click_on_hotbar(mouse_position): # Detects if a mouse input was on a hotbar, blocking other scripts from using that input if it is
	for button in hotbar_buttons:
		var button_rect = button.get_global_rect()
		if button_rect.has_point(mouse_position):
			return true
	return false

func _process(delta: float) -> void: # Updates gun info hud when not reloading and is the mag is not full
	if not reloading and current_ammo != PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"]:
		label.text = str(PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"])+"    "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"])+" | "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"])

func _physics_process(delta): # Runs the handle functions
	health_bar.value = lerp(health_bar.value, PlayerStats.health, 1.0)
	handle_movement(delta)
	handle_rotation(delta)
	handle_stamina(delta)
	handle_health(delta)
	move_and_collide(velocity * delta)
	

func handle_movement(delta): # Detects W-A-S_D input and moves the player accordingly 
	direction = Input.get_vector("left", "right", "up", "down").normalized()
	if direction:
		var speed = PlayerStats.walk_speed # variable for normal speed
		var target_speed = speed
		if Input.is_action_pressed("scoped") and scoped == false:
			scoped = true
			target_speed -= scoped_speed_reduction # Slightly lowers walk speed if scoped
		elif Input.is_action_pressed("sprint") and PlayerStats.stamina > 0 and can_use_stamina == true: # Detects if sprint key is held, stamina is above zero, and that it is usable
			var sprint : float = PlayerStats.walk_speed + 50.0 # variable for speed when sprinting
			target_speed = sprint
			PlayerStats.stamina -= stamina_depletion_rate * delta  # Adjust stamina decrease rate
			PlayerStats.stamina = max(PlayerStats.stamina, 0)  # Ensure stamina does not go below 0
		else:
			scoped = false
		velocity = velocity.move_toward(direction * target_speed, acceleration) # Moves the character
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction) # Stop movement if there is no input
	if velocity == Vector2.ZERO and anim_player.current_animation != PlayerStats.equipped_weapon+"_reload" and anim_player.current_animation != PlayerStats.equipped_weapon+"_shoot": # Changes animation if not reloading, moving or shooting to idle
		anim_player.play(PlayerStats.equipped_weapon+"_idle")
	elif velocity != Vector2.ZERO and anim_player.current_animation != PlayerStats.equipped_weapon+"_reload" and anim_player.current_animation != PlayerStats.equipped_weapon+"_shoot": Changes animation if not reloading or shooting to move
		anim_player.play(PlayerStats.equipped_weapon+"_move")

	if Input.is_action_just_pressed("reload"): # Detects press of reload, and triggers the handle function
		handle_reload()

func handle_rotation(delta): # Handles character rotation
	if Input.is_action_pressed("scoped"):
		rotation_speed = 10.0 # If scoped in it rotates faster
		var mouse_position = get_global_mouse_position()
		target_rotation = (mouse_position - global_position).angle() # If scoped the target is the angle to the mouse
	elif velocity.length() > 0:
		rotation_speed = 7.5
		target_rotation = velocity.angle() # If not scoped rotates towards the direction you're moving
	else:
		return
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta) # Smoothly rotate from a to b

func handle_stamina(delta): # Handles the variables for stamina and the stamina bar
	if PlayerStats.stamina == 0: # If reaches zero, disable the ability to sprint
		can_use_stamina = false
	elif PlayerStats.stamina >= PlayerStats.max_stamina: # Reenables that ability once the stamina is full
		can_use_stamina = true
	if Input.is_action_pressed("sprint") and can_use_stamina == true: # Removes stamina if sprinting and can use stamina
		PlayerStats.stamina -= stamina_depletion_rate * delta # Decrease stamina when sprinting
		PlayerStats.stamina = max(PlayerStats.stamina, 0) # Make sure stamina does not go below 0
	else:
		PlayerStats.stamina += regen_stamina(delta) # Regenerate stamina only if not sprinting
		PlayerStats.stamina = min(PlayerStats.stamina, PlayerStats.max_stamina) # Ensure stamina does not exceed max stamina
	stamina_bar.value = PlayerStats.stamina # Update stamina bar

func regen_stamina(_delta):
	var regen = stamina_regen_rate * pow(2, PlayerStats.stamina / PlayerStats.max_stamina)
	return min(regen, max_regen_rate)

func handle_reload(): # Handle reloading the magazines for both weapons
	if PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] < PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"]:
		reloading = true
		if anim_player.current_animation != PlayerStats.equipped_weapon+"_reload" and anim_player.current_animation != PlayerStats.equipped_weapon+"_shoot" and PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"] > 0:
			anim_player.play(PlayerStats.equipped_weapon+"_reload")
			if PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"] - ((PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"] - PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"])) < 0:
				current_ammo = PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"]
				PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] += PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"]
				PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"] = 0
			else:
				current_ammo = PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"]
				PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"] -= (PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"] - PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"])
				PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] += (PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"] - PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"])

func _on_animation_player_animation_finished(anim_name): # Handles animation state once reload or shoot has ended (they don't loop)
	if anim_name == PlayerStats.equipped_weapon+"_reload" or anim_name == PlayerStats.equipped_weapon+"_shoot":
		if anim_name == PlayerStats.equipped_weapon+"_reload":
			reloading = false # Notes that not currently reloading
			shot_timer.start() # Allows shooting to occur (starts the timer that controls the cooldown between shots)
		if velocity != Vector2.ZERO:
			anim_player.play(PlayerStats.equipped_weapon+"_move") # Plays walk animation if moving
		else:
			anim_player.play(PlayerStats.equipped_weapon+"_idle") # Plays idle if not moving
		current_ammo = PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"]
		label.text = str(PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"])+"    "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"])+" | "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"])

func instantiate_bullet(): # Spawn in bullet
	if PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] <= PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"] and PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] > 0: # Spawns a different bullet depending on the equipped weapon
		var bullet
		match PlayerStats.equipped_weapon:
			"handgun": bullet = handgun_bullet.instantiate()
			"rifle": bullet = rifle_bullet.instantiate()
		#print(str(PlayerStats.equipped_weapon+"_bullet"))
		Shot.emit()
		bullet.global_position = global_position
		bullet.rotate(player.rotation)
		anim_player.play(PlayerStats.equipped_weapon+"_shoot")
		world.add_child(bullet)
		PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] -= 1
		current_ammo = PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"]
		label.text = str(PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"])+"    "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"])+" | "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"])
	elif PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] <= 0:
		handle_reload()

func handle_shooting(): # Calls the instantiate_bullet() function when timer stopped and detects a left click (held or press)
	if Input.is_action_just_pressed("shoot") and shot_timer.is_stopped() and anim_player.current_animation != PlayerStats.equipped_weapon+"_reload":
		instantiate_bullet()
		shot_timer.start()

func _on_shot_cooldown_timeout(): # When the shot timer ends and left click is still held, it shoots again
	if Input.is_action_pressed("shoot") and anim_player.current_animation != PlayerStats.equipped_weapon+"_reload":
		instantiate_bullet()
		shot_timer.start()

func _on_hotbar_gun_swapped(): # Changes timer shot cooldown on weapon change
	label.text = str(PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"])+"    "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"])+" | "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"])
	shot_timer.wait_time = PlayerStats.weapons[PlayerStats.equipped_weapon]["cooldown"]

func handle_health(delta): # Kills the player if health is less than or equal to zero
	if PlayerStats.health <= 0:
		die()

func _on_pickup_zone_area_entered(area: Area2D) -> void: # Triggers collect() on ammo drops
	if area.is_in_group("Pickup"):
		if area.has_method("collect"):
			area.collect()

func die(): # Change to the death screen scene on death
	get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")

func _on_max_health_update(value): # Update the health bar max value on upgrade
	health_bar.max_value = value

func _on_max_stamina_update(value): # Update the stamina bar max value on upgrade
	stamina_bar.max_value = value
