extends Button

func _pressed() -> void: # Quits to the start scene on press
	get_tree().paused = false
	PlayerStats.reset()
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
