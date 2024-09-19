extends HSlider


signal VolumeUpdate

func _ready():
	value = Volume.music_volume

func _value_changed(new_value):
	if new_value == -100:
		Volume.music_volume = -80
		VolumeUpdate.emit()
	else:
		Volume.music_volume = new_value*0.2
		VolumeUpdate.emit()
