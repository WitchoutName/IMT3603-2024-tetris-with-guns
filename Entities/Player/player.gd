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
var effects: Array[Effect] = []
var can_suicide: bool = true
var invis = false
var can_shoot = true
var can_interact = true

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

#nodes
@onready var STATES = $STATES
@onready var Raycasts = $Raycasts
@onready var health: Health = $Health
@onready var health_bar: ProgressBar = $HealthBar
@onready var inventory: Inventory = $Inventory
@onready var Camera: Camera2D = $Camera2D
@onready var AudioListener: AudioListener2D = $AudioListener2D
@onready var EffectsGroup: Node2D = $EffectsGroup
@onready var Username: Label = $Username
@onready var ASprite: AnimatedSprite2D = $AnimatedSprite2D


#Respawn handling
const RESPAWN_TIME = 5
var is_frosen = false
var should_respawn = true

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready():
	health.set_multiplayer_authority(1)
	health_bar.set_multiplayer_authority(1)
	for state in STATES.get_children():
		state.STATES = STATES
		state.Player = self
		prev_state = STATES.IDLE
		current_state = STATES.IDLE
	if player_peer:
		$Username.text = player_peer.username

func _physics_process(delta):
	if not is_multiplayer_authority() and player_peer: return
	if not is_frosen:
		if not ASprite.visible and not invis:
			ASprite.show()
		if is_controlling_tower: _handle_tower_input()
		else: player_input()
	
		change_state(current_state.update(delta))
		move_and_slide()
		#default_move(delta)
	else:
		if ASprite.visible:
			ASprite.hide()

func _handle_tower_input():
	if tower:
		if Input.is_action_just_pressed("tower_move_left"):
			tower.ap_move_left.rpc_id(1)
		if Input.is_action_just_pressed("tower_move_right"):
			tower.ap_move_right.rpc_id(1)
		if Input.is_action_just_pressed("tower_rotate"):
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
		

	if Input.is_action_just_pressed("Suicide") and can_suicide:
		health.take_damage(999)

func _on_health_death():
	inventory.unequip_everything()
	is_frosen = false
	for effect in effects:
		if effect != null:
			effect.remove()
			if effect != null:
				effect.queue_free()
	for effect in EffectsGroup.get_children():
		if effect != null:
			effect.remove()
			if effect != null:
				effect.queue_free()

func spawn():
	is_frosen = false

func respawn():
	if not should_respawn:
		return
	hide()
	#Wait five seconds
	await get_tree().create_timer(5).timeout
	health.set_health(health.max_health)
	show()
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


func create_wound(bullet: Bullet):
	var splatter_scene: PackedScene = bullet.blood_splatter
	var location: Vector2 = bullet.collision_pos
	var _rotation: float = bullet.collision_rot
	if splatter_scene:
		var splatter: CPUParticles2D = splatter_scene.instantiate()
		add_child(splatter)
		splatter.position = to_local(location)
		splatter.rotate(_rotation)
		splatter.emitting = true
		print(_rotation, to_local(location), location)
