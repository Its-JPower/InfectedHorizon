extends CharacterBody2D


@export var speed = 200.0
@export var acceleration = 40.0
@onready var sprite = $Sprite
@export var friction = 50.0
@export var shot = false
@export var reload = false

@onready var animator = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

var direction = Vector2.ZERO
var target = Vector2.ZERO

func _physics_process(delta):
	direction = Input.get_vector("left","right","up","down").normalized()
	if Input.is_action_pressed("move"):
		target = get_global_mouse_position()
	if global_position.distance_to(target) > 5:
		if Input.is_action_pressed("move"):
			velocity = global_position.direction_to(target) * speed
			sprite.rotation = velocity.angle()
	if direction:
		velocity = velocity.move_toward(direction * speed, acceleration)
		sprite.rotation = velocity.angle()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction)
	if Input.is_action_just_pressed("reload"):
		reload = true
		sprite.play("handgun_reload")
	move_and_slide()
