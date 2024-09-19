extends Node

signal UpdateHealth
signal UpdateMaxHealth(value)
signal UpdateMaxStamina(value)

var is_paused : bool = false
var time_minutes: int = 0
var time_seconds: int = 0
var total_damage: int = 0
var total_kills: int = 0
var currency = 0
var total_currency = 0
var count = 0
var score = 0
var zombies = 0
var wave_progress = 1
var health: float = 100.0
var max_health: float = 100.0
var defense: float = 0.0
var sprint_speed: float = 150.0
var stamina: float = 100.0
var max_stamina : float = 100.0
var equipped_weapon : String = "handgun"
var walk_speed : float = 100.0
var weapons = {
	"rifle": {"mag": 30, "mag_size": 30, "bullets": 120, "cooldown": 0.1, "damage": 30.0},
	"handgun": {"mag": 8, "mag_size": 8, "bullets": 64, "cooldown": 1.0, "damage": 50.0}}
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
var wave_amount = {1:5, 2:5, 3:10, 4:10, 5:15, 6:15, 7:20, 8:20, 9:25, 10:25, 11:30, 12:30, 13:35, 14:35, 15:40, 16:45, 17:50, 18:55, 19:60, 20:65, 21:70, 22:75, 23:80, 24:85, 25:90, 26:95, 27:100, 28:100, 29:100, 30:100, 31:100, 32:100, 33:100, 34:100, 35:100, 36:100, 37:100, 38:100, 39:100, 40:100, 41:100, 42:100, 43:100, 44:100, 45:100, 46:100, 47:100, 48:100, 49:100, 50:100, 51:100, 52:100, 53:100, 54:100, 55:100, 56:100, 57:100, 58:100, 59:100, 60:100, 61:100, 62:100, 63:100, 64:100, 65:100, 66:100, 67:100, 68:100, 69:100, 70:100, 71:100, 72:100, 73:100, 74:100, 75:100, 76:100, 77:100, 78:100, 79:100, 80:100, 81:100, 82:100, 83:100, 84:100, 85:100, 86:100, 87:100, 88:100, 89:100, 90:100, 91:100, 92:100, 93:100, 94:100, 95:100, 96:100, 97:100, 98:100, 99:100, 100:100};

func die(cause : int):
	match cause:
		0:
			return causes[0]
		1:
			return causes[1]
		2:
			return causes[2]

func reset():
	zombies = 0
	wave_progress = 1
	health = 100.0
	max_health = 100.0
	defense = 0.0
	sprint_speed = 150.0
	stamina = 100.0
	max_stamina  = 100.0
	equipped_weapon = "handgun"
	weapons = {
	"rifle": {"mag": 30, "mag_size": 30, "bullets": 120, "cooldown": 0.1, "damage": 30.0},
	"handgun": {"mag": 8, "mag_size": 8, "bullets": 64, "cooldown": 1.0, "damage": 50.0}}
	currency = 0
	total_currency = 0
	time_minutes = 0
	time_seconds = 0
	total_damage = 0
	total_kills = 0

func upgrade_max_health():
	max_health += 40
	emit_signal("UpdateMaxHealth", max_health)
	
func upgrade_max_stamina():
	max_stamina += 40
	emit_signal("UpdateMaxStamina", max_stamina)
	
func upgrade_rifle_damage():
	weapons["rifle"]["damage"] += 14
	
func upgrade_pistol_damage():
	weapons["handgun"]["damage"] += 10
	
func upgrade_rifle_mag():
	weapons["rifle"]["mag_size"] += 14

func upgrade_pistol_mag():
	weapons["handgun"]["mag_size"] += 14

func upgrade_walk_speed():
	walk_speed += 10.0

func half_heal():
	health += max_health/2
	health = min(health, max_health)

func full_heal():
	health = max_health

func wait_until_unpaused() -> void:
	while get_tree().paused:
		await get_tree().create_timer(0.1).timeout
