extends HSlider

@onready var menu_music = $"../../../../../Menu Music"
@onready var bullet_audio = get_node("/root/Bullet/Audio")

func _value_changed(new_value):
	if new_value == -100:
		menu_music.volume_db = -80
		bullet_audio.volume_db = -80
	else:
		menu_music.volume_db = new_value*(0.15)
		bullet_audio.volume_db = new_value*(0.15)
	print(menu_music.volume_db)
