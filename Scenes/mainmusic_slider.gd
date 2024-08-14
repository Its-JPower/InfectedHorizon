extends HSlider


signal VolumeUpdate

func _value_changed(new_value):
	if new_value == -100:
		Volume.music_volume = -80
		Volume.bullet_volume = -80
		VolumeUpdate.emit()
	else:
		Volume.music_volume = new_value*0.2
		Volume.bullet_volume = new_value*0.2
		VolumeUpdate.emit()
