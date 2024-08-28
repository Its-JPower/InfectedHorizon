extends Button

@onready var die_menu: Control = $".."

func _pressed() -> void:
	die_menu.visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
