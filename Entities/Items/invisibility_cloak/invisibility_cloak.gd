extends Item_Script

func _use():
	invis_player.rpc()

@rpc("any_peer", "call_local")
func invis_player():
	player.invisibility(7.5)
	destruct()
