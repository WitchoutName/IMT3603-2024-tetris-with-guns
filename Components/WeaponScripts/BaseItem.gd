extends Node2D
class_name BaseItem

@export var Preview: PackedScene

@export var destructionInterval = 5
var destructionTimer: Timer = Timer.new()
var is_dupe: bool = false


#Equip handling
@onready var interaction_area: InteractionArea = $InteractionArea
var active = false
var player: Player
var start_orientation
var fire_mode = "click"
signal picked_up


func init():
	pass


func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	start_orientation = rotation
	interaction_area.interact = Callable(self, "_on_interact")
	start_orientation = rotation
	add_child(destructionTimer)
	destructionTimer.timeout.connect(_on_destruction_timer_timeout)
	init()


func _clone_custom(dupe):
	pass

func _clone():
	var dupe = duplicate()
	dupe.set_multiplayer_authority(get_multiplayer_authority())
	dupe.player = player
	dupe.fire_mode = fire_mode
	_clone_custom(dupe)
	dupe.is_dupe = true
	if player:
		player.health.connect("death", dupe.call_drop) #Connecting drop to death signal
	dupe.active = active
	return dupe


func change_parent(location: Node2D = null):
	var dupe = _clone()
	if location:
		location.add_child(dupe)
		dupe.name = name
		dupe.position = Vector2.ZERO
		dupe.interaction_area.enabled = interaction_area.enabled 
		interaction_area.force_remove() #We have to force remove it from the manager
	else:
		var root = get_tree().root
		GameManager.map.item_group.add_child(dupe)
		dupe.name = name
		dupe.position = global_position
		dupe.interaction_area.enabled = interaction_area.enabled
		
	hide()
	if is_multiplayer_authority(): queue_free()
	else: get_tree().create_timer(0.075).timeout.connect(func(): queue_free())
	emit_signal("picked_up")
	return dupe

#On player interaction
func _on_interact(interacted_player: Player):
	destructionTimer.stop()
	if GameManager.my_player.player_peer.id == 1:
		print("host setting multiplayer authority", interacted_player.player_peer.id)
	set_multiplayer_authority(interacted_player.player_peer.id)
	#player = GameManager._players[player_id].entity
	player = interacted_player
	fire_mode = player.inventory.get_fire_mode() #Getting which fire mode to use
	if !fire_mode: #If null returned - slot 3 selected, weapon is not equiped
		fire_mode = "click1"
		return
	if not player.health.is_connected("death", call_drop):
		player.health.connect("death", call_drop) #Connecting drop to death signal
	active = true
	interaction_area.enabled = false 
	interaction_area.force_remove() #We have to force remove it from the manager
	player.inventory.equip_item(self)
	
	
func call_drop():
	_drop.rpc()

func _drop_custom():
	pass

#Handles the weapon drop
@rpc("authority", "call_local")
func _drop():
	rotation = start_orientation
	scale = Vector2.ONE
	active = false
	#Disconnecting from death signal
	if player && player.health.is_connected("death", call_drop):
			player.health.disconnect("death", call_drop)
	player = null
	interaction_area.enabled = true
	
	_drop_custom()
	
	var dupe = change_parent()
	dupe.destructionTimer.start(destructionInterval)
	dupe.set_multiplayer_authority(1)
	
	
func _on_destruction_timer_timeout():
	destroy.rpc()

@rpc("any_peer", "call_local")
func destroy():
	queue_free()
