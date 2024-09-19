extends RichTextLabel

var time_passed: float = 0.0
var timer: int = 0

func _process(delta: float) -> void:
	if not PlayerStats.is_paused:
		time_passed += delta
		if time_passed >= 1.0:
			time_passed = 0.0
			timer += 1
			update_stats()

func update_stats() -> void:
	# Assuming PlayerStats is a singleton or autoload
	PlayerStats.time_minutes = timer / 60
	PlayerStats.time_seconds = timer % 60

	# Update the RichTextLabel's text with the timer, currency, and wave progress
	text = "%02d:%02d\n$%d\nWave %d" % [
		PlayerStats.time_minutes,
		PlayerStats.time_seconds,
		PlayerStats.currency,
		PlayerStats.wave_progress
	]
