extends RichTextLabel

var time_passed = 0.0
var timer = 0

func _process(delta: float) -> void:
	time_passed += delta
	if time_passed >= 1.0:
		time_passed = 0.0
		timer += 1
	update_timer(timer)

func update_timer(timer : int):
	var minutes = timer / 60
	var seconds = timer % 60
	text = "%02d:%02d\n\n" % [minutes, seconds] + str(PlayerStats.score)
