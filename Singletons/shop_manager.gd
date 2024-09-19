extends Node


var shop_prices = {
	"max_health": {1:1000,2:1500,3:2500,4:4000,5:6500,"max":5,"current":0, "method":"upgrade_max_health"},
	"max_stamina": {1:1000,2:1500,3:2500,4:4000,5:6500,"max":5,"current":0, "method":"upgrade_max_stamina"},
	"rifle_damage": {1:500,2:1000,3:1500,4:2500,5:4000,"max":5,"current":0, "method":"upgrade_rifle_damage"},
	"pistol_damage": {1:350,2:500,3:1000,4:2000,5:3500,"max":5,"current":0, "method":"upgrade_pistol_damage"},
	"rifle_mag": {1:750,2:1250,3:2000,4:3000,5:4500,"max":5,"current":0, "method":"upgrade_rifle_mag"},
	"pistol_mag": {1:400,2:650,3:1000,4:2000,5:3500,"max":5,"current":0, "method":"upgrade_pistol_mag"},
	"walk_speed": {1:5000,2:10000,3:25000,"max":3,"current":0, "method":"upgrade_walk_speed"}
	}

var full_price: int = 1000
var full_amount: int = 1
var half_price: int = 650
var half_amount: int = 1

func bought_item(item):
	var current_level = shop_prices[item]["current"]
	var max_level = shop_prices[item]["max"]
	if current_level >= max_level:
		return
	var next_upgrade_cost = shop_prices[item][current_level + 1]
	if PlayerStats.currency >= next_upgrade_cost:
		PlayerStats.currency -= next_upgrade_cost
		shop_prices[item]["current"] += 1
		call_method(shop_prices[item]["method"])
		return "success"
	else:
		return

func call_method(method_name):
	if PlayerStats.has_method(method_name):
		PlayerStats.call(method_name)

func buy_heal(heal):
	if heal == "half":
		var next_upgrade_cost = half_price * half_amount
		if PlayerStats.currency >= next_upgrade_cost:
			PlayerStats.currency -= next_upgrade_cost
			half_amount += 1
			call_method("half_heal")
			return "success"
	elif heal == "full":
		var next_upgrade_cost = full_price * full_amount
		if PlayerStats.currency >= next_upgrade_cost:
			PlayerStats.currency -= next_upgrade_cost
			full_amount += 1
			call_method("full_heal")
			return "success"
