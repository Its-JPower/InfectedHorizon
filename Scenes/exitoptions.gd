extends Button


@onready var menu = $"../../Menu"
@onready var options = $".."
#@onready var option = $"../../Control"

func _pressed():
	if get_tree().current_scene.scene_file_path == "res://Scenes/start_menu.tscn":
		options.visible = false
		menu.visible = true
		print("1")
	else:
		options.visible = false
		menu.visible = true
		print("2")
