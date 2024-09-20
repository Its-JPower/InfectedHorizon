extends Button


@onready var menu = $".."
@onready var options = $"../../Options"

func _pressed(): # Shows the options menu in the main menu (hides everything else: Play,Options,Quit buttons)
	menu.visible = false
	options.visible = true
