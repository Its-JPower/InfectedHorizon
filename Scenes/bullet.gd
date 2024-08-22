extends Area2D


@onready var player = $"."
@export var SPEED = 300

func _process(delta):
	translate(Vector2.RIGHT.rotated(rotation) * SPEED * delta)



func _on_child_entered_tree(node):
	await get_tree().create_timer(5.0).timeout
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	print(self)
	if body.is_in_group("Enemy") and body.has_method("enemy_die"):
		queue_free()
		body.health -= PlayerStats.weapons[PlayerStats.equipped_weapon]["damage"]
		body.update_health(body.health, body.max_health)
		if body.health <= 0:
			body.enemy_die()
