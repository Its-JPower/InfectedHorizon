extends Button


@onready var menu = $"../../Menu"
@onready var options = $".."

func _pressed():
	menu.visible = true
	options.visible = false
