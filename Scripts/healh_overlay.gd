extends TextureRect


func _ready() -> void: Changes the opacity of the health overlay in relation to how much health/how much max health you have.
	self_modulate.a = 0

func _process(delta: float) -> void:
	self_modulate.a = lerp(self_modulate.a,0.75 - PlayerStats.health/PlayerStats.max_health/1.25, 0.1)
