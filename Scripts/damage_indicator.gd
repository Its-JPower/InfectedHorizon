extends Node2D

@export var SPEED: int = 30
@export var FRICTION: int = 15
var SHIFT_DIRECTION: Vector2 = Vector2.ZERO

@onready var label = $Label

func _ready(): # Randomise the spawn location
	SHIFT_DIRECTION = Vector2(randi_range(-1, 1), randi_range(-1, 1))

func _process(delta: float) -> void: # Move is slightly in the direction of the random spawn location
	global_position += SPEED * SHIFT_DIRECTION * delta
	SPEED = max(SPEED - FRICTION * delta, 0)
