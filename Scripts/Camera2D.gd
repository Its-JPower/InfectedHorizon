extends Camera2D




func _on_player_shot():
	zoom = Vector2(3.9,3.9)
	await get_tree().create_timer(0.1).timeout
	zoom = Vector2(4,4)
