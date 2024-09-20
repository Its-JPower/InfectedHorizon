extends GridContainer

signal GunSwapped

@onready var handgun = $handgun
@onready var rifle = $rifle
@onready var sprite = $"../../../Sprite"
@onready var anim_player = $"../../../AnimationPlayer"

# Maps input actions to method names
var buttons = {"slot_1" : "_on_handgun_pressed", "slot_2" : "_on_rifle_pressed"} # Links the slots to a method

func _on_rifle_pressed(delta): # If the rifle slot has been selected (be from either clicking or pressing 2)
	if not rifle.disabled and anim_player.current_animation != PlayerStats.equipped_weapon+"_reload":
		PlayerStats.equipped_weapon = "rifle"
		GunSwapped.emit()
		handgun.flat = true
		rifle.flat = false
		sprite.offset = lerp(Vector2(30.938,-15), Vector2(30.938,-24.25), 2.5 * delta)

func _on_handgun_pressed(delta): # If the handgun slot has been selected (be from either clicking or pressing 1)
	if anim_player.current_animation != PlayerStats.equipped_weapon+"_reload":
		PlayerStats.equipped_weapon = "handgun"
		GunSwapped.emit()
		handgun.flat = false
		rifle.flat = true
		sprite.offset = lerp(Vector2(30.938,-24.25),Vector2(30.938,-15), 2.5 * delta)

func _input(event): # Detects the input for the two slot and calls the corresponding method
	if event.is_action_pressed("slot_1"):
		call_method(buttons["slot_1"], get_process_delta_time())
	elif event.is_action_pressed("slot_2"):
		call_method(buttons["slot_2"], get_process_delta_time())

func call_method(method_name, delta): # Calls a method via a string
	if has_method(method_name):
		call(method_name,delta)
