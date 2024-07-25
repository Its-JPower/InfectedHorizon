extends CharacterBody2D


@export var speed = 200.0
@export var acceleration = 40.0
@onready var sprite = $Sprite
@export var friction = 50.0
@export var shoot = false
@export var reload = false
@export var moving = false

@onready var rich_text_label = $Camera2D/RichTextLabel

var direction = Vector2.ZERO
var target = Vector2.ZERO

func _physics_process(delta):
	direction = Input.get_vector("left","right","up","down").normalized()                                                            
	if direction:
		velocity = velocity.move_toward(direction * speed, acceleration)
		sprite.rotation = velocity.angle()
		moving = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction)
		moving = false
	if Input.is_action_just_pressed("reload"):
		if reload == true:
			pass
		else:
			reload = true
			sprite.play("handgun_reload")
			sprite.frame = 0
	move_and_slide()


func _on_sprite_animation_finished():
	if sprite.animation == "handgun_reload":
		reload = false
		if velocity != Vector2.ZERO:
			sprite.play("handgun_move")
			sprite.frame = 0
		else:
			sprite.play("handgun_idle")
	elif sprite.animation == "handgun_move" and velocity == Vector2.ZERO:
		sprite.play("handgun_idle")
	elif sprite.animation != "handgun_reload":
		sprite.play("handgun_move")
		sprite.frame = 0


func _on_sprite_animation_changed():
	sprite.frame = 0
