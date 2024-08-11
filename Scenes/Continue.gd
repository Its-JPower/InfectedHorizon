extends Button

@onready var control = $".."

func _pressed():
	get_tree().paused = !get_tree().paused
	control.visible = !control.visible

func _input(event):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		control.visible = !control.visible
