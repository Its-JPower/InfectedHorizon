extends Area2D

@export var ammo_amount = 10
var collected = false
@onready var player = get_tree().get_first_node_in_group("Player")

func _procces(delta): # Moves the item towards the player if it has been collected
	if collected:
		if player:
			global_position = global_position.move_toward(player.global_position, 300*delta)

func collect():
	collected = true


func _on_body_entered(body: Node2D) -> void: # Removes the node from the world scene once its been collected
	if body.is_in_group("Player"):
		queue_free()
		PlayerStats.weapons[PlayerStats.equipped_weapon]["bullets"] += ammo_amount
