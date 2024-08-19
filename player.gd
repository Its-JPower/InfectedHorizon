extends CharacterBody2D


signal Shot

@export var speed : float = 100.0 # variable for normal speed
@export var sprint : float = 150.0 # variable for speed when sprinting
@export var acceleration : float = 40.0 # variable for acceleration
@export var friction = 50.0 # variable for friction
@export var rotation_speed: float = 7.5 # variable for smooth rotation speed
@export var scoped_speed_reduction : float = 15.0 # variable for scoped speed reduction
@export var stamina_regen_rate : float = 0.25 # lowest regen rate for stamina
@export var max_regen_rate : float = 3.0 # maximum regen rate for stamina
@export var stamina_depletion_rate : float = 5.0 # stamina decrease rate per second during sprinting
@onready var label = $UI/Control/Ammo
@onready var player = $Sprite
@onready var anim_player = $AnimationPlayer
@onready var stamina_bar = $UI/Control/Stamina
@onready var camera = $Camera2D # Reference to the Camera2D node
var weapons = {
	"rifle": {"mag": 30, "mag_size": 30, "bullets": 120, "cooldown": 0.1},
	"handgun": {"mag": 8, "mag_size": 8, "bullets": 64, "cooldown": 1.0}}
var equipped_weapon = "handgun"
var scoped : bool = false
var shooting : bool = false
var reloading : bool = false
var sprinting : bool = false
var direction = Vector2.ZERO
var target_rotation = 0.0
var can_use_stamina = true
@onready var world = $".."
@onready var shot_timer = $ShotCooldown
@onready var hotbar_buttons = []
var stamina : float = 100.0
var max_stamina : float = 100.0
const BULLET = preload("res://Scenes/bullet.tscn")

func _ready():
	stamina_bar.value = stamina
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
		elif Input.is_action_pressed("sprint") and stamina > 0 and can_use_stamina == true:
			target_speed = sprint
			stamina -= stamina_depletion_rate * delta  # Adjust stamina decrease rate
			stamina = max(stamina, 0)  # Ensure stamina does not go below 0
		else:
			scoped = false
		velocity = velocity.move_toward(direction * target_speed, acceleration)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction)
	if velocity == Vector2.ZERO and anim_player.current_animation != equipped_weapon+"_reload" and anim_player.current_animation != equipped_weapon+"_shoot":
		anim_player.play(equipped_weapon+"_idle")
	elif velocity != Vector2.ZERO and anim_player.current_animation != equipped_weapon+"_reload" and anim_player.current_animation != equipped_weapon+"_shoot":
		anim_player.play(equipped_weapon+"_move")

	if Input.is_action_just_pressed("reload"):
		handle_reload()

func handle_rotation(delta):
	if Input.is_action_pressed("scoped"):
		rotation_speed = 10.0
		target_rotation = get_angle_to(get_global_mouse_position())
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
	elif velocity != Vector2.ZERO:
		rotation_speed = 7.5
		target_rotation = direction.angle()
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

func handle_stamina(delta):
	if stamina == 0:
		can_use_stamina = false
	elif stamina >= max_stamina:
		can_use_stamina = true
	if Input.is_action_pressed("sprint") and can_use_stamina == true:
		stamina -= stamina_depletion_rate * delta # Decrease stamina over time while sprinting
		stamina = max(stamina, 0) # Ensure stamina does not go below 0
	else:
		stamina += regen_stamina(delta) # Regenerate stamina only if not sprinting
		stamina = min(stamina, max_stamina) # Ensure stamina does not exceed max_stamina
	stamina_bar.value = stamina # Update stamina bar to reflect stamina value

func regen_stamina(_delta):
	var regen = stamina_regen_rate * pow(2, stamina / max_stamina)
	return min(regen, max_regen_rate)

func handle_reload():
	if weapons[equipped_weapon]["mag"] < weapons[equipped_weapon]["mag_size"]:
		if anim_player.current_animation != equipped_weapon+"_reload" and anim_player.current_animation != equipped_weapon+"_shoot" and weapons[equipped_weapon]["bullets"] > 0:
			anim_player.play(equipped_weapon+"_reload")
			if weapons[equipped_weapon]["bullets"] - ((weapons[equipped_weapon]["mag_size"] - weapons[equipped_weapon]["mag"])) < 0:
				weapons[equipped_weapon]["mag"] += weapons[equipped_weapon]["bullets"]
				weapons[equipped_weapon]["bullets"] = 0
			else:
				weapons[equipped_weapon]["bullets"] -= (weapons[equipped_weapon]["mag_size"] - weapons[equipped_weapon]["mag"])
				weapons[equipped_weapon]["mag"] += (weapons[equipped_weapon]["mag_size"] - weapons[equipped_weapon]["mag"])
				print(weapons[equipped_weapon]["bullets"])

func _on_animation_player_animation_finished(anim_name):
	if anim_name == equipped_weapon+"_reload" or anim_name == equipped_weapon+"_shoot":
		if anim_name == equipped_weapon+"_reload":
			shot_timer.start()
		if velocity != Vector2.ZERO:
			anim_player.play(equipped_weapon+"_move")
		else:
			anim_player.play(equipped_weapon+"_idle")
		label.text = str(weapons[equipped_weapon]["bullets"])+"    "+str(weapons[equipped_weapon]["mag"])+" | "+str(weapons[equipped_weapon]["mag_size"])

func instantiate_bullet():
	if weapons[equipped_weapon]["mag"] <= weapons[equipped_weapon]["mag_size"] and weapons[equipped_weapon]["mag"] > 0:
		var bullet = BULLET.instantiate()
		Shot.emit()
		bullet.global_position = global_position
		bullet.rotate(player.rotation)
		anim_player.play(equipped_weapon+"_shoot")
		world.add_child(bullet)
		weapons[equipped_weapon]["mag"] -= 1
		label.text = str(weapons[equipped_weapon]["bullets"])+"    "+str(weapons[equipped_weapon]["mag"])+" | "+str(weapons[equipped_weapon]["mag_size"])
	elif weapons[equipped_weapon]["mag"] <= 0:
		handle_reload()

func handle_shooting():
	if Input.is_action_just_pressed("shoot") and shot_timer.is_stopped() and anim_player.current_animation != equipped_weapon+"_reload":
		instantiate_bullet()
		shot_timer.start()

func _on_shot_cooldown_timeout():
	if Input.is_action_pressed("shoot") and anim_player.current_animation != equipped_weapon+"_reload":
		instantiate_bullet()
		shot_timer.start()


func _on_hotbar_gun_swapped():
	label.text = str(weapons[equipped_weapon]["bullets"])+"    "+str(weapons[equipped_weapon]["mag"])+" | "+str(weapons[equipped_weapon]["mag_size"])
	shot_timer.wait_time = weapons[equipped_weapon]["cooldown"]
