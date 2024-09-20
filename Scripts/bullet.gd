extends Area2D


@export var SPEED = 300
@onready var coll: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func _process(delta): # Translate the bullet in one direction immediately after being instantiated
	translate(Vector2.RIGHT.rotated(rotation) * SPEED * delta)



func _on_child_entered_tree(node): # Removes node from tree after five seconds
	await get_tree().create_timer(5.0).timeout
	queue_free()


func _on_body_entered(body: Node2D) -> void: # Detects if the bullet hit an enemy, and if so deals damage and despawns the bullet
	if body.is_in_group("Enemy") and body.has_method("enemy_die"):
		#sprite.visible = false
		#coll.visible = false
		body.health -= PlayerStats.weapons[PlayerStats.equipped_weapon]["damage"]
		body.update_health(body.health, body.max_health)
		body.spawn_dmgIndicator(PlayerStats.weapons[PlayerStats.equipped_weapon]["damage"])
		PlayerStats.currency += 10
		PlayerStats.total_currency += 10
		PlayerStats.total_damage += PlayerStats.weapons[PlayerStats.equipped_weapon]["damage"]
		if body.health <= 0: # Execute the enemy die function if the enemy's health lowers to or below 0
			body.enemy_die()
