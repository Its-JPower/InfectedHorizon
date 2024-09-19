extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "ⓘ W-A-S-D to Move
	ⓘ Left Click to Shoot
	ⓘ Right Click to Scope-in
	ⓘ 1-2 to Cycle Weapons
	ⓘ R to reload"
	await get_tree().create_timer(10.0).timeout
	queue_free()
