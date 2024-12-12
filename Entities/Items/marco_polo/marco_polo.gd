extends Item_Script

var shout = load("res://Entities/Items/marco_polo/marco_shout_text.tscn")
var event = load("res://Entities/Items/marco_polo/marco_event.tscn")

var max_distance: int = 650

func _use():
	call_marco.rpc()

@rpc("any_peer", "call_local")
func call_marco():
	var shout_obj = shout.instantiate()
	shout_obj.global_position = player.global_position
	GameManager.map.add_child(shout_obj)
	
	var c_player = GameManager.my_player
	if c_player == player:
		return
	
	if c_player.global_position.distance_to(player.global_position) < max_distance:
		var event_obj = event.instantiate()
		event_obj.anchor_left = 0.5
		event_obj.anchor_right = 0.5
		event_obj.global_position.y -= -100

		GameManager.map.get_node("HUD").get_node("Display").add_child(event_obj)
	
	destruct()
