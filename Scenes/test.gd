extends RichTextLabel



func _process(delta: float) -> void:
	text = "Zombies: "+str(PlayerStats.zombies)+"
	Wave: "+str(PlayerStats.wave_progress)+"
	Wave Amount: "+str(PlayerStats.wave_amount[PlayerStats.wave_progress])
