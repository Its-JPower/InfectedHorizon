extends Node2D

@onready var enemy_spawner: Node2D = $Player/Camera2D/EnemySpawner
const ZOMBIE = preload("res://Scenes/zombie.tscn")
var wave_spawned : bool = false

func _ready() -> void:
	wave_spawned = true
	spawnWave(PlayerStats.wave_amount[PlayerStats.wave_progress])

func spawnWave(count : int): # Spawns a wave of zombies, 'count' is a queue, the zombies queue up and wait to be spawned
	if PlayerStats.zombies <= 0:
		await get_tree().create_timer(4.0).timeout
	while count > 0:
		await get_tree().create_timer(1.0).timeout
		await PlayerStats.wait_until_unpaused() # If paused it waits
		count -= 1 # Minus 1 from queue
		enemy_spawner.spawn_enemy() # Spawns enemy from queue
		PlayerStats.zombies += 1 # Adds a zombie to total alive zombies
	wave_spawned = false
	if PlayerStats.wave_progress == 20:
		get_tree().change_scene_to_file("res://Scenes/win_screen.tscn")

func _process(delta: float) -> void:
	await get_tree().create_timer(10.0).timeout
	if PlayerStats.zombies <= 0 and wave_spawned == false:
		wave_spawned = true
		spawnWave(PlayerStats.wave_amount[PlayerStats.wave_progress])
