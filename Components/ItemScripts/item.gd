extends Node2D
class_name Item_Script

#Equip handling
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D
var active = false
var player


# Called when the node enters the scene tree for the first time.
func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	_init()

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#On player interaction
func _on_interact(interacted_player: Player):
	if interacted_player:
		set_multiplayer_authority(interacted_player.player_peer.id)
		player = interacted_player
		player.health.connect("death", Callable(self, "call_drop")) #Connecting drop to death signal
		active = true
		player.inventory.equip_item(self)
		sprite.hide()
		interaction_area.enabled = false 
		interaction_area.force_remove() #We have to force remove it from the manager

func call_drop():
	_drop.rpc()

#Handles the weapon drop
@rpc("authority", "call_local")
func _drop():
	change_parent()
	active = false
	#Disconnecting from death signal
	if player && player.health.is_connected("call_drop", Callable(self, "_respawn_player")):
			player.health.disconnect("call_drop", Callable(self, "_respawn_player"))
	if player && player.spawned: #If the player is spawned we make the item interactble again 
		interaction_area.force_add()
	player.inventory.clear_slot_item()
	player = null
	sprite.show()
	interaction_area.enabled = true
	set_multiplayer_authority(1)

func change_parent(location: Node2D = null):
	if location:
		reparent(location)
		position = Vector2.ZERO
	else:
		var root = get_tree().root
		reparent(GameManager.map.item_group)
