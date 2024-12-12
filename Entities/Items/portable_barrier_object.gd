extends Item_Script

@export var barrier: PackedScene

func _use():
	place.rpc()

@rpc("any_peer", "call_local")
func place():
	var bar = barrier.instantiate()
	bar.global_position = player.global_position

	GameManager.map.add_child(bar)
	bar.set_multiplayer_authority(multiplayer.get_unique_id())
	
	
	destruct()
