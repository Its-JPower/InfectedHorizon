extends Button


func _pressed() -> void: # Restart the game
	get_tree().paused = false
	PlayerStats.reset()
	get_tree().reload_current_scene()
