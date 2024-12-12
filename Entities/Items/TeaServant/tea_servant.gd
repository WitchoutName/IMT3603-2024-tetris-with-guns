extends Item_Script

@export var effect_scene: PackedScene

func _use():
	use.rpc()

@rpc("any_peer", "call_local")
func use():
	var effect: Effect = effect_scene.instantiate()
	effect.apply(player)
	destruct()
