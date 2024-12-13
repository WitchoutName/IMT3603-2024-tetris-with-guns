extends BaseItem
class_name Melee

#Handles the weapon drop
@rpc("authority", "call_local")
func _drop():
	rotation = start_orientation
	scale = Vector2.ONE
	active = false
	#Disconnecting from death signal
	if player && player.health.is_connected("death", call_drop):
			player.health.disconnect("death", call_drop)
	player.inventory.remove(self)
	player = null
	interaction_area.enabled = true
	
	_drop_custom()
	
	var dupe = change_parent()
	dupe.call_deferred("_reset_properties")
	dupe.destructionTimer.start(destructionInterval)
	dupe.set_multiplayer_authority(1)

#Moves the item outside of player without creating a duplicate
func _change_parent(location: Node2D = null):
	if location:
		reparent(location)
		position = Vector2.ZERO
	else:
		reparent(GameManager.map.item_group)

#Unequips, but does not deactivate the weapon.
#IMPORTANT - Needs to also clear inventory slot after use
@rpc("authority", "call_local")
func _active_unequip():
	_change_parent()
	#Disconnecting from death signal
	if player && player.health.is_connected("death", call_drop):
			player.health.disconnect("death", call_drop)
	player = null
	destructionTimer.start(destructionInterval)
	set_multiplayer_authority(1)

func _clone_custom(dupe):
	dupe.call_deferred("_apply_properties")

#Applies on-pickup properties
func _apply_properties():
	pass

#Handles property reset on drop
func _reset_properties():
	pass

@rpc("any_peer", "call_local")
func _look_at(mouse_pos):
	look_at(mouse_pos)
