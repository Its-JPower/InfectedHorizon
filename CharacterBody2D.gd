extends CharacterBody2D

signal StaminaUpdate

@export var speed : float = 100.0 #normal speed
@export var sprint : float = 150.0 #speed when sprinting
@export var acceleration : float = 40.0
@onready var player = $Sprite
@onready var anim_player = $AnimationPlayer
@export var friction = 50.0
@export var rotation_speed: float = 5.0  #rotation speed for player rotation

var equipped_weapon = "Pistol"
var scoped : bool = false
var shooting : bool = false
var reloading : bool = false
var sprinting : bool = false
var direction = Vector2.ZERO
var target = Vector2.ZERO
var target_rotation = 0.0

var stamina := 100.0
var max_stamina := 100.0
var stamina_regen_rate := 0.01
var max_regen_rate := 1.0

func _physics_process(delta):
	direction = Input.get_vector("left","right","up","down").normalized()                                                            
	if direction:
		if Input.is_action_pressed("scoped"):
			velocity = velocity.move_toward(direction * (speed-15), acceleration)
		else:
			velocity = velocity.move_toward(direction * (speed), acceleration)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction)
	if Input.is_action_just_pressed("reload"):
		if anim_player.current_animation != "handgun_reload" and anim_player.current_animation != "handgun_shoot":
			anim_player.play("handgun_reload")
	if Input.is_action_pressed("scoped"):
		target_rotation = get_angle_to(get_global_mouse_position())
		player.rotation = lerp_angle(player.rotation, target_rotation, rotation_speed * delta)
	elif velocity != Vector2.ZERO:
		target_rotation = direction.angle()
		player.rotation = lerp_angle(player.rotation, target_rotation, rotation_speed * delta)
	if stamina < max_stamina:
		stamina += regen_stamina(delta)
		stamina = min(stamina, max_stamina)
		StaminaUpdate.emit()
	move_and_slide()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "handgun_reload" or anim_name == "handgun_shoot":
		if sprinting == false:
			anim_player.play("handgun_idle")
		else:
			anim_player.play("handgun_move")

func regen_stamina(delta):
	var regen = stamina_regen_rate * pow(2, stamina / max_stamina)
	return min(regen, max_regen_rate) * delta
