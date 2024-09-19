extends TextureRect


func _ready() -> void:
	self_modulate.a = 0

func _process(delta: float) -> void:
	self_modulate.a = lerp(self_modulate.a,0.75 - PlayerStats.health/PlayerStats.max_health/1.25, 0.1)
