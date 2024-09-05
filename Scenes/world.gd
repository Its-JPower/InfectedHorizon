extends Node2D

@onready var enemy_spawner: Node2D = $Player/Camera2D/EnemySpawner
const ZOMBIE = preload("res://Scenes/zombie.tscn")

func _ready() -> void:
	spawnWave(PlayerStats.wave_amount[PlayerStats.wave_progress])

func spawnWave(count : int):
	if PlayerStats.zombies == 0:
		await get_tree().create_timer(4.0).timeout
	while count > 0:
		await get_tree().create_timer(1.0).timeout
		count -= 1
		enemy_spawner.spawn_enemy()
		PlayerStats.zombies += 1
