extends BaseItem
class_name Item_Script

@onready var sprite = $Sprite2D

#_init and _use should be overwritten in the item specific script
func _init():
	pass

func _use():
	pass

func _input(event):
	if not is_multiplayer_authority():
		return
	
	if active && event.is_action_pressed("useItem"):
		_use()

#On player interaction
func _on_interact(interacted_player: Player):
	destructionTimer.stop()
	set_multiplayer_authority(interacted_player.player_peer.id)
	player = interacted_player
	player.health.connect("death", Callable(self, "call_drop")) #Connecting drop to death signal
	active = true
	player.inventory.equip_item(self)
	sprite.hide()
	interaction_area.enabled = false 
	interaction_area.force_remove() #We have to force remove it from the manager

func _clone_custom(dupe):
	dupe.call_deferred("_hide")

#Responsible for showing and hiding item icon on pick-up/drop
func _hide():
	sprite.hide()

func _show():
	sprite.show()

func call_drop():
	_drop.rpc()

#Handles the item drop
@rpc("authority", "call_local")
func _drop():
	scale = Vector2.ONE
	active = false
	#Disconnecting from death signal
	if player && player.health.is_connected("death", call_drop):
			player.health.disconnect("death", call_drop)
	player.inventory.clear_slot_item()
	player = null
	interaction_area.enabled = true
	
	_drop_custom()
	
	var dupe = change_parent()
	dupe.call_deferred("_show")
	dupe.destructionTimer.start(destructionInterval)
	dupe.set_multiplayer_authority(1)
