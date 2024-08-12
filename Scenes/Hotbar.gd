extends GridContainer

signal GunSwapped

@onready var handgun = $handgun
@onready var rifle = $rifle
@onready var player = $"../../.."
@onready var sprite = $"../../../Sprite"
@onready var anim_player = $"../../../AnimationPlayer"

# Maps input actions to method names
var buttons = {"slot_1" : "_on_handgun_pressed", "slot_2" : "_on_rifle_pressed"}

func _on_rifle_pressed(delta):
	if not rifle.disabled and anim_player.current_animation != player.equipped_weapon+"_reload":
		player.equipped_weapon = "rifle"
		print(player.equipped_weapon)
		GunSwapped.emit()
		handgun.flat = true
		rifle.flat = false
		sprite.offset = lerp(Vector2(30.938,-15), Vector2(30.938,-24.25), 2.5 * delta)

func _on_handgun_pressed(delta):
	if anim_player.current_animation != player.equipped_weapon+"_reload":
		player.equipped_weapon = "handgun"
		print(player.equipped_weapon)
		GunSwapped.emit()
		handgun.flat = false
		rifle.flat = true
		sprite.offset = lerp(Vector2(30.938,-24.25),Vector2(30.938,-15), 2.5 * delta)

func _input(event):
	if event.is_action_pressed("slot_1"):
		call_method(buttons["slot_1"], get_process_delta_time())
	elif event.is_action_pressed("slot_2"):
		call_method(buttons["slot_2"], get_process_delta_time())

func call_method(method_name, delta):
	if has_method(method_name):
		call(method_name,delta)
