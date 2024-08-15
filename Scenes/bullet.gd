extends Area2D


@onready var player = $"."
@export var SPEED = 250

func _process(delta):
	translate(Vector2.RIGHT.rotated(rotation) * SPEED * delta)



func _on_child_entered_tree(node):
	await get_tree().create_timer(5.0).timeout
	queue_free()
