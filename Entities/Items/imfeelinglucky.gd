extends Item_Script

@export var weapons: Array[PackedScene]
@export var granade: PackedScene

func _use():
	spawn_weapon.rpc()

@rpc("any_peer", "call_local")
func spawn_weapon():
	#Random number determines the outcome
	var index = RandomNumberGenerator.new().randi_range(0, len(weapons) * 3)
	
	#1/3 to create a weapon
	if index <= len(weapons):
		var weapon: Node2D
		if index == len(weapons): #a chance for it to be a active granade
			weapon = granade.instantiate()
		else:
			weapon = weapons[index].instantiate()
		
		weapon.name = weapon.name+"_"+str(weapon.get_instance_id())
		GameManager.map.add_child(weapon)
		weapon.global_position = global_position
	
	#Some other effects (preferebly keep below 1/3)
	if index == (len(weapons) + 1): #Heal
		player.heal_over_max_health(50)
	if index == (len(weapons) + 2): #Damage
		player.damage(35)
	if index == (len(weapons) + 3): #Teleports to random player
		player.global_poisition = get_random_player_pos()
	
	#Nothing
	
	_drop()
	$InteractionArea.force_remove()
	queue_free()
	

func get_random_player_pos() -> Vector2:
	var positions = []
	for p in GameManager.players:
		if p != player:
			positions.append(p.entity.global_position)
	
	#If no other players, we return player's position, i.e. de facto do nothing
	if positions.size() <= 0: 
		return player.global_position
	
	#Returning position of random player
	var random_index = randi() % positions.size()  
	return positions[random_index]
