extends CharacterBody2D


@export var speed = 100.0
@export var acceleration = 20.0
@onready var sprite = $Sprite
@export var friction = 10.0

var direction = Vector2.ZERO


func _physics_process(delta):
	direction = Input.get_vector("left","right","up","down").normalized()
	if direction:
		velocity = velocity.move_toward(direction * speed, acceleration)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction)
	sprite.rotate(direction)

	move_and_slide()
