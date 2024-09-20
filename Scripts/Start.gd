extends Button


func _pressed(): # Changes to world scene when pressed
	get_tree().change_scene_to_file("res://Scenes/world.tscn")
