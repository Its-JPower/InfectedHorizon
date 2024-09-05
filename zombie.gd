extends CharacterBody2D


var speed = 100
var player_chase = false
var player: Node2D = null
@export var health: float = 100.0
@export var max_health: float = 100.0
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var world: Node2D = $".."
@onready var enemy_spawner: Node2D = $"../Player/Camera2D/EnemySpawner"
const AMMO = preload("res://Scenes/ammo.tscn")
var probability : int = 75
var isinrange = false

func _ready():
	progress_bar.value = health
	randomize()

func _process(delta: float) -> void:
	progress_bar.rotation = 0
	if isinrange:
		handle_attack(0)

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
		if PlayerStats.health - PlayerStats.damage[attack_origin] <= 0 and isinrange:
			await anim_player.animation_finished
			PlayerStats.health -= PlayerStats.damage[attack_origin]
			PlayerStats.health = min(PlayerStats.health, 0)
			PlayerStats.UpdateHealth.emit()
			PlayerStats.die(attack_origin)
		elif isinrange:
			await anim_player.animation_finished
			PlayerStats.health -= PlayerStats.damage[attack_origin]
			PlayerStats.UpdateHealth.emit()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack" and velocity != Vector2.ZERO:
		anim_player.play("move")
	elif anim_name == "attack":
		anim_player.play("idle")

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_chase = true

func _on_detection_area_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body == player:
			speed = 100
			player_chase = false
			velocity = Vector2.ZERO
			isinrange = true
			handle_attack(0)
		else:
			player = body
			player_chase = true

func _on_detection_area_2_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_chase = true
		isinrange = false
		speed = 105
		await get_tree().create_timer(0.25).timeout
		speed = 100

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_chase = false
		player = null
		isinrange = false
		anim_player.play("walk")

func update_health(value,max_value):
	progress_bar.max_value = max_value
	progress_bar.value = value

func enemy_die():
	PlayerStats.zombies -= 1
	queue_free()
	var new_ammo = AMMO.instantiate()
	new_ammo.global_position = global_position
	add_sibling(new_ammo)
	if PlayerStats.zombies <= 0:
		PlayerStats.wave_progress += 1
		world.spawnWave(PlayerStats.wave_amount[PlayerStats.wave_progress])
