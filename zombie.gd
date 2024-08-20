extends CharacterBody2D

@export var speed = 110
var player_chase = false
var player: Node2D = null
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	if player_chase and player != null:
		# Calculate the direction to the player
		var direction = (player.position - position).normalized()
		
		# Move the character towards the player
		velocity = direction * speed
		move_and_slide()

		# Rotate the character to face the player
		rotation = direction.angle()

		# Play the "move" animation if not already playing
		if anim_player.current_animation != "move" and anim_player.current_animation != "attack":
			anim_player.play("move")
	else:
		# Stop the character if not chasing
		velocity = Vector2.ZERO
		if not anim_player.current_animation == "attack":
			anim_player.play("idle")

func handle_attack(attack_origin : int):
	if anim_player.current_animation != "attack":
		anim_player.play("attack")
		await anim_player.animation_finished
		if PlayerStats.health - PlayerStats.damage[attack_origin] <= 0:
			PlayerStats.health -= PlayerStats.damage[attack_origin]
			PlayerStats.health = min(PlayerStats.health, 0)
			PlayerStats.die(attack_origin)
		else:
			PlayerStats.health -= PlayerStats.damage[attack_origin]
			print(PlayerStats.health)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack" and velocity != Vector2.ZERO:
		anim_player.play("move")
	elif anim_name == "attack":
		anim_player.play("idle")

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_detection_area_2_body_entered(body: Node2D) -> void:
	if body == player:
		speed = 100
		player_chase = false
		velocity = Vector2.ZERO
		handle_attack(0)
	else:
		player = body
		player_chase = true

func _on_detection_area_2_body_exited(body: Node2D) -> void:
	player = body
	player_chase = true
	speed = 110
