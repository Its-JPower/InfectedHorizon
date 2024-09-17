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
const DAMAGE_INDICATOR = preload("res://Scenes/damage_indicator.tscn")

func _ready():
	progress_bar.value = health
	player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	progress_bar.rotation = 0
	if isinrange:
		handle_attack(0)

func _physics_process(delta: float) -> void:
	var direction = (player.position - position).normalized() # Calculate the direction to the player
	velocity = direction * speed # Moves the enemy towards the player
	move_and_slide()
	rotation = direction.angle() # Rotate the character to face the player
	if anim_player.current_animation != "move" and anim_player.current_animation != "attack": # Play the "move" animation if not already playing
		anim_player.play("move")

func handle_attack(attack_origin : int):
	if anim_player.current_animation != "attack":
		anim_player.play("attack")
		if PlayerStats.health - PlayerStats.damage[attack_origin] <= 0 and isinrange:
			await anim_player.animation_finished
			if isinrange:
				PlayerStats.health -= PlayerStats.damage[attack_origin]
				PlayerStats.health = min(PlayerStats.health, 0)
				PlayerStats.UpdateHealth.emit()
				PlayerStats.die(attack_origin)
		elif isinrange:
			await anim_player.animation_finished
			if isinrange:
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
		velocity = Vector2.ZERO
		isinrange = true
		handle_attack(0)

func _on_detection_area_2_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		isinrange = false

func update_health(value,max_value):
	progress_bar.max_value = max_value
	progress_bar.value = value

func enemy_die():
	PlayerStats.currency += 100
	PlayerStats.total_currency += 100
	PlayerStats.score += 10
	PlayerStats.zombies -= 1
	queue_free()
	var new_ammo = AMMO.instantiate()
	new_ammo.global_position = global_position
	add_sibling(new_ammo)
	if PlayerStats.zombies <= 0:
		PlayerStats.wave_progress += 1
		world.spawnWave(PlayerStats.wave_amount[PlayerStats.wave_progress])

func spawn_effect(EFFECT: PackedScene, effect_position: Vector2 = global_position):
	if EFFECT:
		var effect = EFFECT.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = effect_position
		effect.label.text = str(PlayerStats.weapons[PlayerStats.equipped_weapon]["damage"])
	

func spawn_dmgIndicator(damage):
	var indicator = spawn_effect(DAMAGE_INDICATOR)
	#indicator.label.text = str(damage)
