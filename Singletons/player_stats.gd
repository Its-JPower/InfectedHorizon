extends Node


signal UpdateHealth

var health: float = 100.0
var max_health: float = 100.0
var defense: float = 0.0
var sprint_speed: float = 150.0
var stamina: float = 100.0
var max_stamina : float = 100.0
var weapons = {
	"rifle": {"mag": 30, "mag_size": 30, "bullets": 120, "cooldown": 0.1},
	"handgun": {"mag": 8, "mag_size": 8, "bullets": 64, "cooldown": 1.0}}
var causes = {
	0: "zombie_attack",
	1: "zombie_burn",
	2: "suicide"
}
var damage = {
	0: 10,
	1: 15,
	2: 2147483647
}

func die(cause : int):
	match cause:
		0:
			return causes[0]
		1:
			return causes[1]
		2:
			return causes[2]
