extends PanelContainer

@onready var btn_max_health: Button = $MarginContainer/VBoxContainer/btn_max_health
@onready var btn_max_stamina: Button = $MarginContainer/VBoxContainer/btn_max_stamina
@onready var btn_rifle_damage: Button = $MarginContainer/VBoxContainer/btn_rifle_damage
@onready var btn_pistol_damage: Button = $MarginContainer/VBoxContainer/btn_pistol_damage
@onready var btn_rifle_mag: Button = $MarginContainer/VBoxContainer/btn_rifle_mag
@onready var btn_pistol_mag: Button = $MarginContainer/VBoxContainer/btn_pistol_mag
@onready var btn_half_heal: Button = $MarginContainer/VBoxContainer/btn_half_heal
@onready var btn_full_heal: Button = $MarginContainer/VBoxContainer/btn_full_heal
@onready var btn_walk_speed: Button = $MarginContainer/VBoxContainer/btn_walk_speed

func _on_btn_max_health_pressed() -> void: # Handles updating text for max health button
	if ShopManager.bought_item("max_health") == "success":
		var current_level = ShopManager.shop_prices["max_health"]["current"]
		var max_level = ShopManager.shop_prices["max_health"]["max"]
		if current_level >= max_level:
			btn_max_health.text = "Max Health"
		else:
			var next_price = ShopManager.shop_prices["max_health"][current_level + 1]
			btn_max_health.text = "Upgrade Max Health $" + str(next_price)

func _on_btn_max_stamina_pressed() -> void: # Handles updating text for max stamina button
	if ShopManager.bought_item("max_stamina") == "success":
		var current_level = ShopManager.shop_prices["max_stamina"]["current"]
		var max_level = ShopManager.shop_prices["max_stamina"]["max"]
		if current_level >= max_level:
			btn_max_stamina.text = "Max Stamina"
		else:
			var next_price = ShopManager.shop_prices["max_stamina"][current_level + 1]
			btn_max_stamina.text = "Upgrade Max Stamina $" + str(next_price)

func _on_btn_rifle_damage_pressed() -> void: # Handles updating text for rifle damage button
	if ShopManager.bought_item("rifle_damage") == "success":
		var current_level = ShopManager.shop_prices["rifle_damage"]["current"]
		var max_level = ShopManager.shop_prices["rifle_damage"]["max"]
		if current_level >= max_level:
			btn_rifle_damage.text = "Max Rifle Damage"
		else:
			var next_price = ShopManager.shop_prices["rifle_damage"][current_level + 1]
			btn_rifle_damage.text = "Upgrade Rifle Damage $" + str(next_price)

func _on_btn_pistol_damage_pressed() -> void: # Handles updating text for handgun damage button
	if ShopManager.bought_item("pistol_damage") == "success":
		var current_level = ShopManager.shop_prices["pistol_damage"]["current"]
		var max_level = ShopManager.shop_prices["pistol_damage"]["max"]
		if current_level >= max_level:
			btn_pistol_damage.text = "Max Pistol Damage"
		else:
			var next_price = ShopManager.shop_prices["pistol_damage"][current_level + 1]
			btn_pistol_damage.text = "Upgrade Pistol Damage $" + str(next_price)

func _on_btn_rifle_mag_pressed() -> void: # Handles updating text for rifle mag button
	if ShopManager.bought_item("rifle_mag") == "success":
		var current_level = ShopManager.shop_prices["rifle_mag"]["current"]
		var max_level = ShopManager.shop_prices["rifle_mag"]["max"]
		if current_level >= max_level:
			btn_rifle_mag.text = "Max Rifle Magazine"
		else:
			var next_price = ShopManager.shop_prices["rifle_mag"][current_level + 1]
			btn_rifle_mag.text = "Upgrade Rifle Magazine $" + str(next_price)

func _on_btn_pistol_mag_pressed() -> void: Handles updating text for handgun mag button
	if ShopManager.bought_item("pistol_mag") == "success":
		var current_level = ShopManager.shop_prices["pistol_mag"]["current"]
		var max_level = ShopManager.shop_prices["pistol_mag"]["max"]
		if current_level >= max_level:
			btn_pistol_mag.text = "Max Handgun Magazine"
		else:
			var next_price = ShopManager.shop_prices["pistol_mag"][current_level + 1]
			btn_pistol_mag.text = "Upgrade Handgun Magazine $" + str(next_price)

func _on_btn_walk_speed_pressed() -> void:andles updating text for walk speed button
	if ShopManager.bought_item("walk_speed") == "success":
		var current_level = ShopManager.shop_prices["walk_speed"]["current"]
		var max_level = ShopManager.shop_prices["walk_speed"]["max"]
		if current_level >= max_level:
			btn_walk_speed.text = "Max Walk Speed"
		else:
			var next_price = ShopManager.shop_prices["walk_speed"][current_level + 1]
			btn_walk_speed.text = "Upgrade Walk Speed $" + str(next_price)

func _on_btn_half_heal_pressed() -> void: Handles updating text for half heal button
	if ShopManager.buy_heal("half") == "success":
		btn_half_heal.text = "Purchase Half Heal $"+str(ShopManager.half_price*ShopManager.half_amount)

func _on_btn_full_heal_pressed() -> void: Handles updating text for full heal button
	if ShopManager.buy_heal("full") == "success":
		btn_full_heal.text = "Purchase Full Heal $"+str(ShopManager.full_price*ShopManager.full_amount)
