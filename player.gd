extends CharacterBody2D


signal Shot

@onready var health_bar: TextureProgressBar = $UI/Control/Health
@export var speed : float = 100.0 # variable for normal speed
@export var sprint : float = 150.0 # variable for speed when sprinting
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
var rotation_speed = 7.5
var target_rotation = 0.0

func _ready():
	stamina_bar.value = PlayerStats.stamina
	var grid_container = $UI/Control/Hotbar
	for button in grid_container.get_children():
		if button is Button:
			hotbar_buttons.append(button)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if not is_click_on_hotbar(event.position):
				handle_shooting()

func is_click_on_hotbar(mouse_position):
	for button in hotbar_buttons:
		var button_rect = button.get_global_rect()
		if button_rect.has_point(mouse_position):
			return true
	return false

func _physics_process(delta):
	health_bar.value = lerp(health_bar.value, PlayerStats.health, 1.0)
	handle_movement(delta)
	handle_rotation(delta)
	handle_stamina(delta)
	move_and_slide()
	

func handle_movement(delta):
	direction = Input.get_vector("left", "right", "up", "down").normalized()
	if direction:
		var target_speed = speed
		if Input.is_action_pressed("scoped") and scoped == false:
			scoped = true
			target_speed -= scoped_speed_reduction
		elif Input.is_action_pressed("sprint") and PlayerStats.stamina > 0 and can_use_stamina == true:
			target_speed = sprint
			PlayerStats.stamina -= stamina_depletion_rate * delta  # Adjust stamina decrease rate
			PlayerStats.stamina = max(PlayerStats.stamina, 0)  # Ensure stamina does not go below 0
		else:
			scoped = false
		velocity = velocity.move_toward(direction * target_speed, acceleration)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction)
	if velocity == Vector2.ZERO and anim_player.current_animation != PlayerStats.equipped_weapon+"_reload" and anim_player.current_animation != PlayerStats.equipped_weapon+"_shoot":
		anim_player.play(PlayerStats.equipped_weapon+"_idle")
	elif velocity != Vector2.ZERO and anim_player.current_animation != PlayerStats.equipped_weapon+"_reload" and anim_player.current_animation != PlayerStats.equipped_weapon+"_shoot":
		anim_player.play(PlayerStats.equipped_weapon+"_move")

	if Input.is_action_just_pressed("reload"):
		handle_reload()

func handle_rotation(delta):
	if Input.is_action_pressed("scoped"):
		rotation_speed = 10.0
		var mouse_position = get_global_mouse_position()
		target_rotation = (mouse_position - global_position).angle()
	elif velocity.length() > 0:
		rotation_speed = 7.5
		target_rotation = velocity.angle()
	else:
		return
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

func handle_stamina(delta):
	if PlayerStats.stamina == 0:
		can_use_stamina = false
	elif PlayerStats.stamina >= PlayerStats.max_stamina:
		can_use_stamina = true
	if Input.is_action_pressed("sprint") and can_use_stamina == true:
		PlayerStats.stamina -= stamina_depletion_rate * delta # Decrease stamina when sprinting
		PlayerStats.stamina = max(PlayerStats.stamina, 0) # Make sure stamina does not go below 0
	else:
		PlayerStats.stamina += regen_stamina(delta) # Regenerate stamina only if not sprinting
		PlayerStats.stamina = min(PlayerStats.stamina, PlayerStats.max_stamina) # Ensure stamina does not exceed max stamina
	stamina_bar.value = PlayerStats.stamina # Update stamina bar

func regen_stamina(_delta):
	var regen = stamina_regen_rate * pow(2, PlayerStats.stamina / PlayerStats.max_stamina)
	return min(regen, max_regen_rate)

func handle_reload():
	if PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] < PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"]:
		if anim_player.current_animation != PlayerStats.equipped_weapon+"_reload" and anim_player.current_animation != PlayerStats.equipped_weapon+"_shoot" and PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"] > 0:
			anim_player.play(PlayerStats.equipped_weapon+"_reload")
			if PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"] - ((PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"] - PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"])) < 0:
				PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] += PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"]
				PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"] = 0
			else:
				PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"] -= (PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"] - PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"])
				PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] += (PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"] - PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"])
				print(PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"])

func _on_animation_player_animation_finished(anim_name):
	if anim_name == PlayerStats.equipped_weapon+"_reload" or anim_name == PlayerStats.equipped_weapon+"_shoot":
		if anim_name == PlayerStats.equipped_weapon+"_reload":
			shot_timer.start()
		if velocity != Vector2.ZERO:
			anim_player.play(PlayerStats.equipped_weapon+"_move")
		else:
			anim_player.play(PlayerStats.equipped_weapon+"_idle")
		label.text = str(PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"])+"    "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"])+" | "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"])

func instantiate_bullet():
	if PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] <= PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"] and PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] > 0:
		var bullet
		match PlayerStats.equipped_weapon:
			"handgun": bullet = handgun_bullet.instantiate()
			"rifle": bullet = rifle_bullet.instantiate()
		print(str(PlayerStats.equipped_weapon+"_bullet"))
		Shot.emit()
		bullet.global_position = global_position
		bullet.rotate(player.rotation)
		anim_player.play(PlayerStats.equipped_weapon+"_shoot")
		world.add_child(bullet)
		PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] -= 1
		label.text = str(PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"])+"    "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"])+" | "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"])
	elif PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"] <= 0:
		handle_reload()

func handle_shooting():
	if Input.is_action_just_pressed("shoot") and shot_timer.is_stopped() and anim_player.current_animation != PlayerStats.equipped_weapon+"_reload":
		instantiate_bullet()
		shot_timer.start()

func _on_shot_cooldown_timeout():
	if Input.is_action_pressed("shoot") and anim_player.current_animation != PlayerStats.equipped_weapon+"_reload":
		instantiate_bullet()
		shot_timer.start()

func _on_hotbar_gun_swapped():
	label.text = str(PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"])+"    "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag"])+" | "+str(PlayerStats.weapons[PlayerStats.equipped_weapon]["mag_size"])
	shot_timer.wait_time = PlayerStats.weapons[PlayerStats.equipped_weapon]["cooldown"]

func handle_health(delta):
	#if PlayerStats.health < PlayerStats.max_health and PlayerStats.health > 0:
		#PlayerStats.health += PlayerStats
	pass
