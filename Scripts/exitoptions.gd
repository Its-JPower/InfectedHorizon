extends Button


@onready var menu = $"../../Menu"
@onready var options = $".."
#@onready var option = $"../../Control"

func _pressed(): # Hides the option menu
	if get_tree().current_scene.scene_file_path == "res://Scenes/start_menu.tscn":
		options.visible = false
		menu.visible = true
	else:
		options.visible = false
		menu.visible = true
