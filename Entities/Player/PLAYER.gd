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
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var last_direction = Vector2.RIGHT

#mechanics
var can_dash = true

#tetris
var tower: Tower2
var is_controlling_tower: bool = false
var piece_catied: Tetramino2
var move_direction: float

#states
var current_state = null
var prev_state = null

#nodes
@onready var STATES = $STATES
@onready var Raycasts = $Raycasts


func _ready():
	for state in STATES.get_children():
		state.STATES = STATES
		state.Player = self
		prev_state = STATES.IDLE
		current_state = STATES.IDLE

func _physics_process(delta):
	
	if is_controlling_tower: _handle_tower_input()
	else: player_input()
	
	change_state(current_state.update(delta))
	move_and_slide()
	#default_move(delta)

func _handle_tower_input():
	if tower.active_piece:
		if Input.is_action_just_pressed("tower_move_left"):
			tower.ap_move_left()
		if Input.is_action_just_pressed("tower_move_right"):
			tower.ap_move_right()
		if Input.is_action_just_pressed("tower_rotate"):
			tower.ap_rotate()

func gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func change_state(input_state):
	if input_state != null:
		prev_state = current_state
		current_state = input_state
		
		prev_state.exit_state()
		current_state.enter_state()

func get_next_to_wall():
	for raycast in Raycasts.get_children():
		raycast.force_raycast_update()
		if raycast.is_colliding():
			if raycast.target_position.x > 0:
				return Vector2.RIGHT
			else:
				return Vector2.LEFT
	return null

func player_input():
	movement_input = Vector2.ZERO
	if Input.is_action_pressed("MoveRight"):
		movement_input.x += 1
	if Input.is_action_pressed("MoveLeft"):
		movement_input.x -= 1
	#if Input.is_action_pressed("MoveUp"):
		#movement_input.y -= 1
	#if Input.is_action_pressed("MoveDown"):
		#movement_input.y += 1
		
	# Jumps
	if Input.is_action_pressed("Jump"):
		jump_input = true
	else: 
		jump_input = false
	if Input.is_action_just_pressed("Jump"):
		jump_input_actuation = true
	else:
		jump_input_actuation = false
	
	#Climb
	#if Input.is_action_pressed("Climb"):
		#climb_input = true
	#else: 
		#climb_input = false	
		
	#dash
	if Input.is_action_just_pressed("Dash"):
		dash_input = true
	else: 
		dash_input = false 


func _on_health_death():
	queue_free()
	#Further death logic will be implemented here
