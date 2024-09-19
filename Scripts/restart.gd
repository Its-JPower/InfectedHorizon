extends Button


func _pressed() -> void:
	get_tree().paused = false
	PlayerStats.reset()
	get_tree().reload_current_scene()
