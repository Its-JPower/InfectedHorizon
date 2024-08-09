extends CharacterBody2D

@export var speed : float = 100.0 # variable for normal speed
@export var sprint : float = 150.0 # variable for speed when sprinting
@export var acceleration : float = 40.0 # variable for acceleration
@export var friction = 50.0 # variable for friction
@export var rotation_speed: float = 5.0 # variable for smooth rotation speed
@export var scoped_speed_reduction : float = 15.0 # variable for scoped speed reduction
@export var stamina_regen_rate : float = 0.25 # lowest regen rate for stamina
@export var max_regen_rate : float = 3.0 # maximum regen rate for stamina
@export var stamina_depletion_rate : float = 5.0 # stamina decrease rate per second during sprinting

@onready var label = $UI/Control/Label
@onready var player = $Sprite
@onready var anim_player = $AnimationPlayer
@onready var stamina_bar = $UI/Control/Stamina
@onready var camera = $Camera2D # Reference to the Camera2D node
var equipped_weapon = "Pistol"
var scoped : bool = false
var shooting : bool = false
var reloading : bool = false
var sprinting : bool = false
var direction = Vector2.ZERO
var target_rotation = 0.0
var mag_size : int = 8
var mag : int = 8
var can_use_stamina = true


const BULLET = preload("res://Scenes/bullet.tscn")
@onready var world = $".."
@onready var shot_timer = $ShotCooldown

var stamina : float = 100.0
var max_stamina : float = 100.0

func _ready():
	stamina_bar.value = stamina

func _physics_process(delta):
	handle_movement(delta)
	handle_rotation(delta)
	handle_stamina(delta)
	handle_shooting()
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

	if Input.is_action_just_pressed("reload"):
		handle_reload()

func handle_rotation(delta):
	if Input.is_action_pressed("scoped"):
		target_rotation = get_angle_to(get_global_mouse_position())
		player.rotation = lerp_angle(player.rotation, target_rotation, rotation_speed * delta)
	elif velocity != Vector2.ZERO:
		target_rotation = direction.angle()
		player.rotation = lerp_angle(player.rotation, target_rotation, rotation_speed * delta)

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

func regen_stamina(delta):
	var regen = stamina_regen_rate * pow(2, stamina / max_stamina)
	return min(regen, max_regen_rate)

func handle_reload():
	if mag < mag_size:
		if anim_player.current_animation != "handgun_reload" and anim_player.current_animation != "handgun_shoot":
			anim_player.play("handgun_reload")
			mag += (mag_size - mag)
			label.text = str(mag)+" | "+str(mag_size)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "handgun_reload" or anim_name == "handgun_shoot":
		anim_player.play("handgun_move" if sprinting else "handgun_idle")

func instantiate_bullet():
	if mag <= mag_size and mag > 0:
		var bullet = BULLET.instantiate()
		bullet.global_position = global_position
		bullet.rotate(player.rotation)
		anim_player.play("handgun_shoot")
		world.add_child(bullet)
		mag -= 1
	elif mag <= 0:
		handle_reload()

func handle_shooting():
	if Input.is_action_just_pressed("shoot") and shot_timer.is_stopped() and anim_player.current_animation != "handgun_reload":
		instantiate_bullet()
		label.text = str(mag)+" | "+str(mag_size)
		shot_timer.start()

func _on_shot_cooldown_timeout():
	if Input.is_action_pressed("shoot") and anim_player.current_animation != "handgun_reload":
		instantiate_bullet()
		label.text = str(mag)+" | "+str(mag_size)
		shot_timer.start()
