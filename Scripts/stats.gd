extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "Total Damage: " + str(PlayerStats.total_damage) + "
	Total Money: " + str(PlayerStats.total_currency) + "
	Total Zombies Killed: " + str(PlayerStats.total_kills) + "
	Total Waves Survived: " + str(PlayerStats.wave_progress-1) + "
	Time Taken: " + str(PlayerStats.time_minutes) + "m " + str(PlayerStats.time_seconds) + "s"
