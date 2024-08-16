extends CharacterBody2D


@export var speed = 25
var player_chase = false
var player = null
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	
	if player_chase:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		position += velocity * delta
		rotation = velocity.angle()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack" and velocity != Vector2.ZERO:
		anim_player.play("move")
	elif anim_name == "attack":
		anim_player.play("idle")


func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true


func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player_chase = false
		velocity = Vector2.ZERO
		anim_player.play("attack")
	else:
		player = body
		player_chase = true
