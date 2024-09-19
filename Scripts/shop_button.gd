extends TextureButton


@onready var shop_menu: PanelContainer = $"../Shop"

func _pressed():
	PlayerStats.is_paused = !PlayerStats.is_paused
	get_tree().paused = !get_tree().paused
	shop_menu.visible = !shop_menu.visible
