extends AudioStreamPlayer2D





func _on_main_music_volume_update():
	volume_db = Volume.music_volume*Volume.master_volume
