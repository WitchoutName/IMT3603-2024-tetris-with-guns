extends Node2D
class_name Melee

@export var destructionInterval = 5
var destructionTimer: Timer = Timer.new()

#Equip handling
@onready var interaction_area: InteractionArea = $InteractionArea
var active = false
var player: Player
var start_orientation
var fire_mode = "click"

func _init():
	print("Is in tree:", is_inside_tree())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("halo2")
	interaction_area.interact = Callable(self, "_on_interact")
	start_orientation = rotation
	add_child(destructionTimer)
	destructionTimer.timeout.connect(_on_destruction_timer_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@rpc("any_peer", "call_local")
func action(delta):
	pass

func change_parent(location: Node2D = null):
	if location:
		reparent(location)
		position = Vector2.ZERO
	else:
		var root = get_tree().root
		reparent(GameManager.map.item_group)


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
	player.inventory.equip_item(self)
	interaction_area.enabled = false 
	interaction_area.force_remove() #We have to force remove it from the manager


func call_drop():
	_drop.rpc()

#Handles the weapon drop
@rpc("authority", "call_local")
func _drop():
	change_parent()
	rotation = start_orientation
	scale = Vector2.ONE
	active = false
	#Disconnecting from death signal
	if player && player.health.is_connected("death", call_drop):
			player.health.disconnect("death", call_drop)
	#if player && player.spawned: #If the player is spawned we make the gun interactble again 
		#interaction_area.force_add()
	player = null
	interaction_area.enabled = true
	destructionTimer.start(destructionInterval)
	set_multiplayer_authority(1)
	
#Unequips, but does not deactivate the weapon
@rpc("authority", "call_local")
func _active_unequip():
	change_parent()
	#Disconnecting from death signal
	if player && player.health.is_connected("death", call_drop):
			player.health.disconnect("death", call_drop)
	#if player && player.spawned: #If the player is spawned we make the gun interactble again 
		#interaction_area.force_add()
	player = null
	destructionTimer.start(destructionInterval)
	set_multiplayer_authority(1)

func _on_destruction_timer_timeout():
	queue_free()
