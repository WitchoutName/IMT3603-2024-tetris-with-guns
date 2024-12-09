extends Item_Script

@export var granade_obj: PackedScene
var throw_speed = 600 #TODO: Make it grow when holding down the button

func _use():
	throw.rpc(get_global_mouse_position())

@rpc("any_peer", "call_local")
func throw(mouse_pos: Vector2):
	#Creating granade
	var granade = granade_obj.instantiate()
	granade.global_position = player.global_position
	
	#Setting direction twords mouse
	var direction = (mouse_pos - global_position).normalized()
	granade.linear_velocity = direction * throw_speed

	GameManager.map.add_child(granade)
	granade.set_multiplayer_authority(multiplayer.get_unique_id())
	
	
	_drop()
	$InteractionArea.force_remove()
	queue_free()
