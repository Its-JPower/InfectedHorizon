extends Node2D


@onready var enemy_spawner: Node2D = $Player/Camera2D/EnemySpawner
const ZOMBIE = preload("res://Scenes/zombie.tscn")
@onready var zombie: CharacterBody2D = $Zombie

func _ready() -> void:
	spawnWave(PlayerStats.wave_amount[PlayerStats.wave_progress])

func spawnWave(count : int):
	while count > 0:
		enemy_spawner.spawn_enemy()
		PlayerStats.zombies += 1
