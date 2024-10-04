# PieceSpawner.gd
extends Node

@export var enabled: bool = true
@export var pieces: Array[PackedScene]

var tower: Tower2
@onready var spawn_marker = $"../SpawnMarker"
var counter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tower = get_parent() as Tower2  # Ensure you're getting the Tower type

func _process(delta: float) -> void:
	# Pooling is fine here, since it's a dev/debug script
	if enabled and tower and not tower.active_piece:
		counter += 1 #
		if counter > 50:
			counter = 0
			# Pick a random piece and instantiate it
			var piece_instance = pieces.pick_random().instantiate() as Tetramino2  # Instantiate the piece
			piece_instance.is_tetris_mode = true
			tower.add_child(piece_instance)  # Add the instance to the tower node
			tower.ap_insert(piece_instance)
