extends Button


@onready var menu = $".."
@onready var options = $"../../Options"


func _pressed():
	menu.visible = false
	options.visible = true
