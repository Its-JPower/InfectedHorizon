extends Node2D

@onready var enemy_spawner: Node2D = $Player/Camera2D/EnemySpawner
const ZOMBIE = preload("res://Scenes/zombie.tscn")

func _ready() -> void:
	spawnWave(PlayerStats.wave_amount[PlayerStats.wave_progress])

func spawnWave(count : int): # Spawns a wave of zombies, 'count' is a queue, the zombies queue up and wait to be spawned
	if PlayerStats.zombies == 0:
		await get_tree().create_timer(4.0).timeout
	while count > 0:
		await get_tree().create_timer(1.0).timeout
		await PlayerStats.wait_until_unpaused() # If paused it waits
		count -= 1 # Minus 1 from queue
		enemy_spawner.spawn_enemy() # Spawns enemy from queue
		PlayerStats.zombies += 1 # Adds a zombie to total alive zombies
