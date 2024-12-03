extends Item_Script

@export var healing_zone: PackedScene

func _use():
	create_healing.rpc()

@rpc("any_peer", "call_local")
func create_healing():
	#Creating healing zone
	var heal_zone = healing_zone.instantiate()
	heal_zone.global_position = player.global_position

	GameManager.map.add_child(heal_zone)
	heal_zone.set_multiplayer_authority(multiplayer.get_unique_id())
	
	
	_drop()
	$InteractionArea.force_remove()
	queue_free()
