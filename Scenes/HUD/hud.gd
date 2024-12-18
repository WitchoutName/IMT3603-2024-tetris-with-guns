extends Node2D

# Declare variables for the UI elements and get references
@onready var team_score_blue = $Display/TopPanel/TeamScoreBlue
@onready var team_score_red = $Display/TopPanel/TeamScoreRed
@onready var timer_label = $Display/TopPanel/Timer
@onready var health_bar = $Display/BottomLeft/HealthBar
@onready var weapon_icon1 = $Display/BottomRight/WeaponIcon1
@onready var weapon_icon2 = $Display/BottomRight/WeaponIcon2
@onready var ammo_label = $Display/BottomRight/Ammo

#Reference to the player and health node
var player: Player
var health: Health
#@export var health: Health

func _ready():
	if not is_instance_valid(health_bar):
		push_error("Error: HealthBar is not valid!")
		return
	GameManager.game_started.connect(get_references)

func get_references():
	player = GameManager.get_my_player()
	if player == null:
		push_error("Player not found!")
		return
	
	health = player.get_node("Health") 
	if health == null:
		push_error("Health node not found!")
		return
	
	#Connecting player signals to health
	player.health.connect("health_changed", Callable(self, "_on_health_change"))
	player.health.connect("death", func(): _on_health_change(0))
	#player.connect("respawned", Callable(self, "_on_health_change"))
	player.inventory.slot_change.connect(_on_inventory_slot_change)
	player.inventory.slot_state_change.connect(_on_inventory_slot_state_change)
	GameManager.map.teams[0].tower.progress_change.connect(func(x: float): update_team_score("blue", x))
	GameManager.map.teams[1].tower.progress_change.connect(func(x: float): update_team_score("red", x))
	
	initialize()




# Team scores
var team_blue_score = 0
var team_red_score = 0

# Function to update team scores locally and propagate via RPC
func update_team_score(team: String, value: float):
	if team == "blue":
		team_blue_score = int(value * 100)
	elif team == "red":
		team_red_score = int(value * 100)

	# Use an RPC to sync scores across all clients
	rpc("sync_team_scores", team_blue_score, team_red_score)  # Broadcast to all peers

	# Update UI locally for the host
	if is_multiplayer_authority():
		update_team_scores_ui(team_blue_score, team_red_score)

# RPC function to synchronize team scores
@rpc("any_peer", "reliable")
func sync_team_scores(blue_score: int, red_score: int):
	team_blue_score = blue_score
	team_red_score = red_score
	update_team_scores_ui(blue_score, red_score)

# Function to update the UI for team scores
func update_team_scores_ui(blue_score: int, red_score: int):
	if team_score_blue != null:
		team_score_blue.value = blue_score / 10
		if team_score_blue.get_child_count() > 0 and team_score_blue.get_child(0) is Label:
			var blue_label_node = team_score_blue.get_child(0)
			blue_label_node.text = str(blue_score) + "%"
	if team_score_red != null:
		team_score_red.value = red_score / 10
		if team_score_red.get_child_count() > 0 and team_score_red.get_child(0) is Label:
			var red_label_node = team_score_red.get_child(0)
			red_label_node.text = str(red_score) + "%"



# Function to update the timer
func update_timer(time_left: int):
	var minutes = time_left / 60
	var seconds = time_left % 60
	if timer_label != null:
		timer_label.text = "%02d:%02d" % [minutes, seconds]

func _on_health_change(h):
	if health != null:
		update_health(health.get_current_health())

# Function to update health
func update_health(health: int):
	if health_bar != null:
		health_bar.value = max(0, health)
		if health_bar.get_child_count() > 0 and health_bar.get_child(0) is Label:
			var health_label_node = health_bar.get_child(0)
			health_label_node.text = str(health) + " / 100"

# Function to update ammo
func update_ammo(current_ammo: int, max_ammo: int):
	if ammo_label != null:
		ammo_label.text = str(current_ammo) + " / " + str(max_ammo)

# Function to highlight the currently selected weapon
func highlight_weapon(weapon_number: int):
	if weapon_icon1 != null and weapon_icon2 != null:
		if weapon_number == 1:
			weapon_icon1.modulate = Color(1, 1, 1, 1)  # Highlight (white)
			weapon_icon2.modulate = Color(0.5, 0.5, 0.5, 1)  # Dim (gray)
		elif weapon_number == 2:
			weapon_icon1.modulate = Color(0.5, 0.5, 0.5, 1)  # Dim (gray)
			weapon_icon2.modulate = Color(1, 1, 1, 1)  # Highlight (white)

# Function to update the weapon icon when a gun is picked up
func _on_gun_picked_up(gun_node: Node):
	print("Received gun_picked_up signal for gun node: ", gun_node)

	if gun_node.has_node("AnimatedSprite2D"):
		var animated_sprite = gun_node.get_node("AnimatedSprite2D")
		if animated_sprite is AnimatedSprite2D:
			var current_texture = animated_sprite.frames.get_frame(animated_sprite.animation, animated_sprite.frame)
			if current_texture != null:
				print("Updating weapon icon with texture from AnimatedSprite2D")
				weapon_icon1.texture = current_texture
			else:
				print("Error: Texture from AnimatedSprite2D is null!")
		else:
			print("Error: Node is not an AnimatedSprite2D")
	elif gun_node is Sprite2D:
		var sprite_texture = gun_node.texture
		if sprite_texture != null:
			print("Updating weapon icon with texture from Sprite2D")
			weapon_icon1.texture = sprite_texture
		else:
			print("Error: Texture from Sprite2D is null!")
	else:
		print("Error: Weapon node is neither Sprite2D nor has AnimatedSprite2D")

func _on_inventory_slot_change(slot: Inventory.ItemSlot):
	match slot:
		Inventory.ItemSlot.RIGHT_HAND:
			$Display/Inventory/Hands/Hands0.hide()
			$Display/Inventory/Hands/Hands1.hide()
			$Display/Inventory/Hands/Hands2.show()
			$Display/Inventory/Hands/Hands3.hide()			
		Inventory.ItemSlot.LEFT_HAND:
			$Display/Inventory/Hands/Hands0.hide()
			$Display/Inventory/Hands/Hands1.show()
			$Display/Inventory/Hands/Hands2.hide()
			$Display/Inventory/Hands/Hands3.hide()
		Inventory.ItemSlot.ITEM_SLOT:
			$Display/Inventory/Hands/Hands0.hide()
			$Display/Inventory/Hands/Hands1.hide()
			$Display/Inventory/Hands/Hands2.hide()
			$Display/Inventory/Hands/Hands3.show()

func _update_slot_preview(slot: Control, item: BaseItem):
	for child in slot.get_children():
		child.queue_free()

	if item != null:
		var preview = (item.Preview if item.Preview else load("res://Entities/Guns/Pistol/PistolPreview.tscn")).instantiate()
		slot.add_child(preview)


var has_two_handed_item: bool = false
func _on_inventory_slot_state_change(slot: Inventory.ItemSlot, item: BaseItem):
	if has_two_handed_item and not item:
		_update_slot_preview($Display/Inventory/Slots/Dual, null)
		has_two_handed_item = false
		return
	
	if item and item.is_in_group("two-handed"):
		_update_slot_preview($Display/Inventory/Slots/LeftHand, null)
		_update_slot_preview($Display/Inventory/Slots/RightHand, null)
		_update_slot_preview($Display/Inventory/Slots/Dual, item)
		has_two_handed_item = true
		return
	
	if item and item.is_in_group("item"):
		_update_slot_preview($Display/Inventory/Slots/ItemHand, item)
		return

	match slot:
		Inventory.ItemSlot.RIGHT_HAND:
			_update_slot_preview($Display/Inventory/Slots/RightHand, item)
		Inventory.ItemSlot.LEFT_HAND:
			_update_slot_preview($Display/Inventory/Slots/LeftHand, item)
		Inventory.ItemSlot.ITEM_SLOT:
			_update_slot_preview($Display/Inventory/Slots/ItemHand, item)

# Function to handle updates based on game state (e.g. health decrease, ammo usage)
func _process(delta):
	pass  # This will be filled in with actual game logic later

# Function to set dummy values for testing
func initialize():
	update_team_scores_ui(0, 0)  
	update_timer(300)
	if health != null:
		update_health(health.get_current_health())
	update_ammo(17, 30)
	highlight_weapon(1)
