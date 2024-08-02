extends CharacterBody2D


@export var speed = 200.0
@export var acceleration = 40.0
@onready var player = $Sprite
@onready var anim_player = $AnimationPlayer
@export var friction = 50.0
var shooting = false
var reloading = false

var direction = Vector2.ZERO
var target = Vector2.ZERO

func _physics_process(delta):
	direction = Input.get_vector("left","right","up","down").normalized()                                                            
	if direction:
		velocity = velocity.move_toward(direction * speed, acceleration)
		player.rotation = velocity.angle()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction)
	if Input.is_action_just_pressed("reload"):
		if anim_player.current_animation != "handgun_reload" and anim_player.current_animation != "handgun_shoot":
			anim_player.play("handgun_reload")
	move_and_slide()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "handgun_reload" or anim_name == "handgun_shoot":
		anim_player.play("handgun_idle")
