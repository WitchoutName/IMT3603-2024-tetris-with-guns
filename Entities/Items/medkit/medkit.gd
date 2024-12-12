extends Item_Script

@export var healing_value = 100

func _use():
	heal_player.rpc()

@rpc("any_peer", "call_local")
func heal_player():
	player.health.heal_up_to_max_health(healing_value)
	
	destruct()
