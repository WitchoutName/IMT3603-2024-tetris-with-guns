extends Area2D

# Exported array of spawnable items with weights
@export var spawnable_items: Array = [
	{"scene": preload("res://Entities/Tower/v2/Tetraminos/shape_i.tscn"), "weight": 2},
	{"scene": preload("res://Entities/Tower/v2/Tetraminos/shape_j.tscn"), "weight": 1},
	{"scene": preload("res://Entities/Tower/v2/Tetraminos/shape_l.tscn"), "weight": 3},
	{"scene": preload("res://Entities/Tower/v2/Tetraminos/shape_o.tscn"), "weight": 3},
	{"scene": preload("res://Entities/Tower/v2/Tetraminos/shape_s.tscn"), "weight": 3},
	{"scene": preload("res://Entities/Tower/v2/Tetraminos/shape_t.tscn"), "weight": 3},
	{"scene": preload("res://Entities/Tower/v2/Tetraminos/shape_z.tscn"), "weight": 3},
]

@export var respawn_time: float = 1.0

# Timer for managing respawn delay
@onready var spawn_timer: Timer = Timer.new()  
var is_piece_active: bool = false  
var current_piece: Node = null  

func _ready() -> void:
	# Configure and add the timer
	spawn_timer.wait_time = 1.0
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

	# Spawn the first piece
	spawn_random_piece()


# Function to spawn a random piece from the spawnable_items array
func spawn_random_piece() -> void:
	if is_piece_active:
		return

	var selected_item = select_random_weighted_item()
	if selected_item:
		current_piece = selected_item.instantiate()
		add_child(current_piece)

		# Connect the signal from tetramino.gd
		current_piece.connect("piece_picked_up", Callable(_on_piece_picked_up))
		is_piece_active = true
	else:
		print("No item was selected.")

# Function to select a random item based on defined weights
func select_random_weighted_item() -> PackedScene:
	var total_weight = 0
	
	for item in spawnable_items:
		total_weight += item.weight
	
	var random_weight = randi() % total_weight
	var accumulated_weight = 0

	for item in spawnable_items:
		accumulated_weight += item.weight
		if random_weight < accumulated_weight:
			return item.scene  

	return null

# Called when a piece is picked up
func _on_piece_picked_up() -> void:
	spawn_timer.start(randi_range(1,10))  
	is_piece_active = true  

# Called when the spawn timer times out
func _on_spawn_timer_timeout() -> void:
	is_piece_active = false  
	spawn_random_piece()  
