extends Node2D

@onready var spawn_points = $SpawnPoints.get_children()
@onready var spawn_timer: Timer = $SpawnTimer
@onready var world = get_node("/root/World")
@onready var camera: Camera2D = $".."
const ZOMBIE = preload("res://Scenes/zombie.tscn")


func spawn_enemy(): #Function that adds an enemy as a child of the world scene
	var enemy = ZOMBIE.instantiate()
	var spawn_point = spawn_points.pick_random()
	enemy.global_position = spawn_point.global_position
	world.add_child(enemy)
