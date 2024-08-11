extends GridContainer

signal GunSwapped

@onready var handgun = $handgun
@onready var rifle = $rifle
@onready var player = $"../../.."

# Maps input actions to method names
var buttons = {"slot_1" : "_on_handgun_pressed", "slot_2" : "_on_rifle_pressed"}

func _on_rifle_pressed():
	if rifle.disabled == true:
		pass
	else:
		player.equipped_weapon = "rifle"
		print(player.equipped_weapon)
		GunSwapped.emit()
		handgun.flat = true
		rifle.flat = false

func _on_handgun_pressed():
	player.equipped_weapon = "handgun"
	print(player.equipped_weapon)
	GunSwapped.emit()
	handgun.flat = false
	rifle.flat = true

func _input(event):
	if event.is_action_pressed("slot_1"):
		call_method(buttons["slot_1"])
	elif event.is_action_pressed("slot_2"):
		call_method(buttons["slot_2"])

func call_method(method_name):
	if has_method(method_name):
		call(method_name)
