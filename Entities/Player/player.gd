extends CharacterBody2D
class_name Player
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity_value = ProjectSettings.get_setting("physics/2d/default_gravity")

# player input
var movement_input = Vector2.ZERO
var jump_input = false
var jump_input_actuation = false
var climb_input = false
var dash_input = false

#player movement
@export var SPEED = 70.0
@export var JUMP_VELOCITY = -400.0
var last_direction = Vector2.RIGHT

#mechanics
var can_dash = true

#tetris
var tower: Tower2
var is_controlling_tower: bool = false
var piece_catied: Tetramino2
var move_direction: float

#networking
var player_peer: PlayerPeer

#states
var current_state = null
var prev_state = null

#signals
signal toggle_player_paused(is_paused: bool)



#GameManaging
var player_paused: bool = false:
	get:
		return player_paused
	set(value):
		player_paused = value
		get_tree().paused = player_paused
		emit_signal("toggle_player_paused",player_paused)
	
#nodes
@onready var STATES = $STATES
@onready var Raycasts = $Raycasts
@onready var health = $Health
@onready var inventory: Inventory = $Inventory
@onready var Camera: Camera2D = $Camera2D

#Respawn handling
const RESPAWN_TIME = 5
var spawned = true 
var should_respawn = true

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())
	
func _input(event: InputEvent):
	if (event.is_action_pressed("ui_cancel")):  # 'ui_cancel' is the default for ESC
		#var escape_menu = $CanvasLayer/EscapeMenu
		player_paused = !player_paused
		print(player_paused)
		#escape_menu.visible = !escape_menu.visible

func _ready():
	#var escape_menu = $"CanvasLayer/EscapeMenu"
	print("Game paused state at start: ", get_tree().paused)
	for state in STATES.get_children():
		state.STATES = STATES
		state.Player = self
		prev_state = STATES.IDLE
		current_state = STATES.IDLE
	if player_peer:
		$Username.text = player_peer.username
		
	await get_tree().create_timer(2).timeout
	for action_name in InputMap.get_actions():
		print(action_name, ": ", ", ".join(InputMap.action_get_events(action_name)))
	#if escape_menu:
		#escape_menu.exit_to_lobby.connect(_on_exit_to_lobby)

func _physics_process(delta):
	if not is_multiplayer_authority() and player_peer: return
	if spawned:
		if not $AnimatedSprite2D.visible:
			$AnimatedSprite2D.visible = true
		if is_controlling_tower: _handle_tower_input()
		else: player_input()
	
		change_state(current_state.update(delta))
		move_and_slide()
		#default_move(delta)
	else:
		if $AnimatedSprite2D.visible:
			$AnimatedSprite2D.visible = false

func _handle_tower_input():
	if tower and tower.active_piece:
		if Input.is_action_just_pressed("tower_move_left"):
			print("calling moveleft")
			tower.ap_move_left.rpc_id(1)
		if Input.is_action_just_pressed("tower_move_right"):
			print("calling move right")
			tower.ap_move_right.rpc_id(1)
		if Input.is_action_just_pressed("tower_rotate"):
			print("calling roatate")
			tower.ap_rotate.rpc_id(1)

func gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func change_state(input_state):
	if input_state != null:
		prev_state = current_state
		current_state = input_state
		
		prev_state.exit_state()
		current_state.enter_state()

func get_next_to_wall() -> Vector2:
	for raycast in Raycasts.get_children():
		raycast.force_raycast_update()
		if raycast.is_colliding():
			if raycast.target_position.x > 0:
				return Vector2.RIGHT
			else:
				return Vector2.LEFT
	return Vector2.ZERO

func player_input():
	movement_input = Vector2.ZERO
	print("input")
	if Input.is_action_pressed("move_right"):
		print("right")
		movement_input.x += 1
	if Input.is_action_pressed("move_left"):
		movement_input.x -= 1
	#if Input.is_action_pressed("MoveUp"):
		#movement_input.y -= 1
	#if Input.is_action_pressed("MoveDown"):
		#movement_input.y += 1
		
	# Jumps
	if Input.is_action_pressed("jump"):
		jump_input = true
	else: 
		jump_input = false
	if Input.is_action_just_pressed("jump"):
		jump_input_actuation = true
	else:
		jump_input_actuation = false
	
	#Climb
	#if Input.is_action_pressed("Climb"):
		#climb_input = true
	#else: 
		#climb_input = false	
		
	#dash
	if Input.is_action_just_pressed("dash"):
		dash_input = true
	else: 
		dash_input = false 

func _on_health_death():
	inventory.unequip_everything()
	spawned = false

func spawn():
	spawned = true

func respawn():
	if not should_respawn:
		return
	#Wait five seconds
	await get_tree().create_timer(5).timeout
	health.set_health(health.max_health)
	spawn()

func equip_gun(gun):
	pass
	#equiped_gun = gun
	#if player_peer:
		#gun.set_multiplayer_authority(player_peer.id)

func unequip_gun():
	pass
	#equiped_gun.set_multiplayer_authority(1)
	#equiped_gun = null



# Transition to the lobby scene
func _on_exit_to_lobby():
	# Optional: Handle multiplayer cleanup or save progress
	print("Exiting to lobby...")
	#cleanup_multiplayer()
	get_tree().change_scene("res://Scenes/Menu/lobby/connection_lobby.tscn")

#func cleanup_multiplayer():
	#if Multiplayer.is_server():
		#print("Stopping server...")
		#Multiplayer.stop()
	#elif Multiplayer.is_client():
		#print("Disconnecting from server...")
		#Multiplayer.disconnect()
	## Optional: Clear the Multiplayer API
	#Multiplayer.clear_peers()
