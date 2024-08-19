extends Button

var paused = false
@onready var control = $".."

func _pressed():
	paused = false
	get_tree().paused = !get_tree().paused
	control.visible = !control.visible

func _input(event):
	if Input.is_action_just_pressed("pause") and paused == false:
		paused = true
		get_tree().paused = !get_tree().paused
		control.visible = !control.visible
