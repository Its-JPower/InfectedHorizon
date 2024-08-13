extends HSlider


@onready var menu_music = $"../../../../../Menu Music"

func _value_changed(new_value):
	menu_music.volume_db = new_value*(0.8)
	print(menu_music.volume_db)
