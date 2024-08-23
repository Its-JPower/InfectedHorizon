extends Node2D

@onready var enemy_spawner: Node2D = $Player/Camera2D/EnemySpawner
const ZOMBIE = preload("res://Scenes/zombie.tscn")
@onready var zombie: CharacterBody2D = $Zombie

func _ready() -> void:
	spawnWave(PlayerStats.wave_amount[PlayerStats.wave_progress])

func spawnWave(count : int):
	while count > 0:
		await get_tree().create_timer(1.0).timeout
		count -= 1
		enemy_spawner.spawn_enemy()
		PlayerStats.zombies += 1


func _on_zombie_spawn_wave_signal() -> void:
	print("e")
	await get_tree().create_timer(5.0).timeout
	print("ee")
	PlayerStats.wave_progress += 1
	enemy_spawner.spawnWave(PlayerStats.wave_amount[PlayerStats.wave_progress])
