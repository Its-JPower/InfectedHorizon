extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void: # Tutorial text that shows at the beginning of the game for 10 seconds
	text = "ⓘ W-A-S-D to Move
	ⓘ Left Click to Shoot
	ⓘ Right Click or Q to Scope-in
	ⓘ 1-2 to Cycle Weapons
	ⓘ R to reload"
	await get_tree().create_timer(10.0).timeout
	queue_free()
