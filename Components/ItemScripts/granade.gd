extends Item_Script

@export var granade_obj: PackedScene
var throw_speed = 600 #TODO: Make it grow when holding down the button

func _use():
	#Creating granade
	var granade = granade_obj.instantiate()
	granade.global_position = player.global_position
	#Throwing twords mouse
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	granade.linear_velocity = direction * throw_speed

	get_tree().current_scene.add_child(granade)
	
	
	_drop()
	$InteractionArea.force_remove()
	queue_free()
