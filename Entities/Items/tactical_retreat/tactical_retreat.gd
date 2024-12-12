extends Item_Script

@onready var flag = load("res://Entities/Items/tactical_retreat/tactical_retreat_used.tscn")

func _use():
	add_flag.rpc()
	

@rpc("call_local", "any_peer")
func add_flag():
	player.add_child(flag.instantiate())
	
	destruct()
