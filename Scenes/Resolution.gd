extends OptionButton


func _ready():
	selected = Volume.resolution_index

func _on_item_selected(index):
	Volume.resolution_index = index
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600,900))
		2:
			DisplayServer.window_set_size(Vector2i(1280,720))
