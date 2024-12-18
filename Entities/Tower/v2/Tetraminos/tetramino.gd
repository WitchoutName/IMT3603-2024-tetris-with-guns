extends RigidBody2D
class_name Tetramino2

# Declare the picked_up signal
signal picked_up  

# RigidBody mode
@onready var interaction_area: InteractionArea = $InteractionArea
@export var is_picked_up: bool = false
var player: Player:
	set = _set__player
var tower: Tower2:
	set = _set__tower
var base_scales: Dictionary = {} # dict[Node2D: Array[Vector2]]

# Tetris mode
@export var shape: TetraminoClass.PIECE_SHAPE
var matrix: Array
var data: TetraminoClass
@export var is_tetris_mode: bool = false:
	set = _set__is_tetris_mode
@export var is_petrified: bool = false:
	set = _set__is_petrified
var console_color: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Init of the tetris variables
	matrix = TetraminoClass.shape_matrices[shape]
	data = TetraminoClass.new()
	data.rotation = 0
	data.position = Vector2(0, 0)
	console_color = ["#", "@", "%", "W", "$", "&", "E"].pick_random()
	#Init of RigidBody variables
	for child in get_children():
		if child is Node2D:
			base_scales.get_or_add(child, [Vector2.ONE * child.scale, Vector2.ONE * child.transform.origin])
	scale(Vector2(0.5, 0.5))
	freeze = false
	interaction_area.interact = Callable(self, "_on_interact") #Assigning interact function
	mass = 0.25
	linear_damp = 1




func sync(grid_size: Vector2):
	"""
	Synchronizes the piece transform based on data variable
	"""
	position.x = data.position.x * 50 - grid_size.x/2 * 50 + 75
	position.y = - (grid_size.y - data.position.y) * 50 + 75
	rotation = data.rotation * PI/2


func _set__is_petrified(value: bool):
	if self:
		is_petrified = value
		var material = preload("res://Shaders/GrayScale/GrayScaleMaterial.tres")
		$Sprite2D.material = material if value else null
		interaction_area.enabled = not value
		if value: InteractionManager.remove_area(interaction_area)

func _set__is_tetris_mode(value: bool):
	is_tetris_mode = value
	freeze = value
	scale(Vector2(1, 1) if value else Vector2(0.5, 0.5))

func _set__player(value: Player):
	if value:
		player = value
		get_parent().remove_child(self)
		player.add_child(self)
		position = Vector2(0, 0)
		scale(Vector2(0.25, 0.25))
	elif player: 
		var root = get_tree().root
		player.remove_child(self)
		root.get_children()[1].add_child(self)
		position = player.position
		scale(Vector2(0.5, 0.5))
		player = null

	
func _on_interact(_player: Player):
	if  is_picked_up == true:
		
		release()
	else: 
		if !_player.can_interact:
			return
		
		attach(_player)
		#This is for spawning pieces
		emit_signal("picked_up")
	
	if tower: 
		tower.steal(self)

	

func scale(factor: Vector2):
	"""
	transform.scale of RigidBodyes is broken in godot and all childeren have to be scaled instead
	"""
	# Apply scale to all children before we reset it
	for child in get_children():
		if child is Node2D:
			child.scale = base_scales[child][0] * factor
			child.transform.origin = base_scales[child][1] * factor

func attach(_player: Player):
	#print("CollisionPolygon2D exists:", $CollisionPolygon2D != null)
	if _player:
		$CollisionPolygon2D.disabled = true
		freeze = true
		is_picked_up = true
		player = _player
		player.piece_catied = self
		print("attach() completed, player:", player)
		print(is_picked_up)

func release():
	#print("CollisionPolygon2D exists:", $CollisionPolygon2D != null)
	if player:
		print("releasing piece")
		$CollisionPolygon2D.disabled = false
		player.piece_catied = null
		is_picked_up = false
		player = null
		is_tetris_mode = false
		


func _set__tower(value: Tower2):
	if not value:
		for piece in data.pieces_above:
			piece.data.pieces_below.erase(self)
			if len(piece.data.pieces_below) == 0:
				tower.steal(piece)
		data.pieces_above = []
		data.pieces_below = []
		is_tetris_mode = false
		
	tower = value
