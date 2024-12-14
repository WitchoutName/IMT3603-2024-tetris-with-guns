extends Item_Script

@export var effect_scene: PackedScene

func _use():
	invis_player.rpc()

@rpc("any_peer", "call_local")
func invis_player():
	var invis_effect: Effect = effect_scene.instantiate()
	invis_effect.apply(player)
	destruct()
