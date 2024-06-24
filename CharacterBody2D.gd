extends CharacterBody2D


@export var speed = 200.0
@export var acceleration = 40.0
@onready var sprite = $Sprite
@export var friction = 50.0

var direction = Vector2.ZERO
var target = Vector2.ZERO


func _physics_process(delta):
	direction = Input.get_vector("left","right","up","down").normalized()
	sprite.rotation = global_position.direction_to(get_global_mouse_position()).angle()
	if Input.is_action_pressed("move"):
		target = get_global_mouse_position()
	if global_position.distance_to(target) > 5:
		if Input.is_action_pressed("move"):
			velocity = global_position.direction_to(target) * speed
			if sprite.animation == "default":
				sprite.play("default")
	if velocity.x == 0:
		sprite.play("default")
	if direction:
		velocity = velocity.move_toward(direction * speed, acceleration)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction)
	move_and_slide()
