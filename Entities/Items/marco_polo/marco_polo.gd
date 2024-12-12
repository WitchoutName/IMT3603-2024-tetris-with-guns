extends Item_Script

var max_distance: int = 650

func _use():
	call_marco.rpc()

@rpc("any_peer", "call_local")
func call_marco():
	var player_pos = []
	for p in GameManager.players:
		if p.entity != player:
			player_pos.append(p.entity.global_position)
	
	for pos in player_pos:
		if player.global_position.distance_to(pos) < max_distance:
			pass
	
	destruct()
