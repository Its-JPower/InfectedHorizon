extends HSlider


signal VolumeUpdate

func _ready():
	value = Volume.master_volume/0.2

func _value_changed(new_value):
	if new_value == -100:
		Volume.master_volume = -80
		VolumeUpdate.emit()
	else:
		Volume.master_volume = new_value*0.2
		VolumeUpdate.emit()
