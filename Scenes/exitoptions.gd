extends Button


@onready var menu = $"../../Menu"
@onready var options = $".."
@onready var option = $"../../Control"

func _pressed():
	if get_tree().current_scene == "res://Scenes/start_menu.tscn":
		options.visible = false
		option.visible = true
	else:
		options.visible = false
		menu.visible = true
