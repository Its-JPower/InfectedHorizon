extends TextureRect


func _process(delta: float) -> void:
	self_modulate.a = 0.75 - PlayerStats.health/PlayerStats.max_health/1.25
