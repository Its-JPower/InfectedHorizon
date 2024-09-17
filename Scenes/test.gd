extends RichTextLabel



func _process(delta: float) -> void:
	text = "$"+str(PlayerStats.currency)+"
	Wave: "+str(PlayerStats.wave_progress)
