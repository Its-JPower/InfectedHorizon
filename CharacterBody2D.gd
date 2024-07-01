extends CharacterBody2D


@export var speed = 200.0
@export var acceleration = 40.0
@onready var sprite = $Sprite
@export var friction = 50.0
@export var shot = false

enum state {IDLE, RUNNING, JUMPUP, JUMPDOWN, HURT}

var anim_state = state.IDLE

@onready var animator = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

var direction = Vector2.ZERO
var target = Vector2.ZERO

func update_state():
	if anim_state == state.HURT:
		return
	if shot == true:
		anim_state = state.JUMPUP
	if velocity == Vector2.ZERO:
		anim_state = state.IDLE
	elif velocity.x != 0:
		anim_state = state.RUNNING

func update_animation(direction):
	match anim_state:
		state.IDLE:
			animation_player.play("handgun_idle")
		state.RUNNING:
			animation_player.play("handgun_move")
		state.HURT:
			animation_player.play("handgun_hurt")
		state.JUMPUP:
			animation_player.play("handgun_shoot")

func _physics_process(delta):
	direction = Input.get_vector("left","right","up","down").normalized()
	if Input.is_action_pressed("move"):
		target = get_global_mouse_position()
	if global_position.distance_to(target) > 5:
		if Input.is_action_pressed("move"):
			velocity = global_position.direction_to(target) * speed
			sprite.rotation = velocity.angle()
	if velocity.x == 0:
		sprite.play("handgun_idle")
	if direction:
		velocity = velocity.move_toward(direction * speed, acceleration)
		sprite.rotation = velocity.angle()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction)
	update_state()
	update_animation(direction)
	move_and_slide()
