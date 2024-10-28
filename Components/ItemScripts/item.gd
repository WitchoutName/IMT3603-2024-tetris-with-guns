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
	if event.is_action_pressed("useItem"):
		_use()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player:
		global_position = player.global_position

#On player interaction
func _on_interact(interacted_player: Player):
	player = interacted_player
	player.health.connect("death", Callable(self, "_drop")) #Connecting drop to death signal
	active = true
	player.inventory.equip_item(self)
	sprite.hide()
	interaction_area.enabled = false 
	interaction_area.force_remove() #We have to force remove it from the manager

#Handles the weapon drop
func _drop():
	active = false
	#Disconnecting from death signal
	if player && player.health.is_connected("death", Callable(self, "_respawn_player")):
			player.health.disconnect("death", Callable(self, "_respawn_player"))
	if player && player.spawned: #If the player is spawned we make the gun interactble again 
		interaction_area.force_add()
	player.inventory.clear_slot_item()
	player = null
	sprite.show()
	interaction_area.enabled = true
