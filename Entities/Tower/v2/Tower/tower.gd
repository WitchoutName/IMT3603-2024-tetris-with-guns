extends Node2D
class_name Tower2

@export var active_piece: Tetramino2
@export var tower_dimensions: Vector2 = Vector2(10, 20)
@export var petrify_width: int = 6
@export_range(1, 10, 0.1) var fall_speed: float = 7.5
var grid: GridClass
var piece_queue: Array[Tetramino2]

signal win()
signal progress_change(percentage: float)

func _ready():
	grid = GridClass.new(tower_dimensions, petrify_width)
	_init_bg()
	$MoveDownTimer.wait_time = 1 - (fall_speed-1)/10


func _process(delta: float) -> void:
	pass

@rpc("any_peer", "call_local")
func ap_insert(piece_path):
	if not multiplayer.is_server(): return
	var piece: Tetramino2 = get_node(piece_path)
	if active_piece or len(piece_queue) > 0:
		piece_queue.append(piece)
	else:
		active_piece = piece
		piece.interaction_area.enabled = false
		grid.attach_piece(piece)

@rpc("any_peer", "call_local")
func ap_move_left(): # ap -> active piece
	if not multiplayer.is_server(): return
	print("ap_move_left")
	grid.move_left()

@rpc("any_peer", "call_local")	
func ap_move_right():
	if not multiplayer.is_server(): return
	print("ap_move_RIGHT")
	grid.move_right()

@rpc("any_peer", "call_local")
func ap_rotate():
	if not multiplayer.is_server(): return
	print("ap_rotate")
	grid.rotate()

func steal(piece: Tetramino2):
	grid.remove_piece(piece)
	piece.tower = null
	progress_change.emit(grid.get_progress())

func _on_move_down_timer_timeout() -> void:
	if not multiplayer.is_server(): return
	if active_piece:
		if not grid.move_down():
			grid.dettach_piece()
			active_piece.interaction_area.enabled = true
			if len(piece_queue) > 0:
				active_piece = piece_queue.pop_at(0)
				active_piece.interaction_area.enabled = false
				grid.attach_piece(active_piece)
			else: active_piece = null
			progress_change.emit(grid.get_progress())
			if grid.is_win_state():
				_on_win()
				return
			grid.petrify_complete_row()
			

func _on_win():
	_emit_win.rpc()
	_emit_win()

@rpc("reliable", "any_peer")
func _emit_win():
	emit_signal(win.get_name(), self)

func reset():
	
	if active_piece:
		active_piece.queue_free()
	active_piece = null
	for piece in piece_queue:
		piece.queue_free()
	for x in grid.matrix:
		for y in x:
			if y:
				y.queue_free()
				y = null	
	grid = GridClass.new(tower_dimensions, petrify_width)
	_init_bg()
	$MoveDownTimer.wait_time = 1 - (fall_speed-1)/10


func _init_bg():
	
	$PetrifyZone.position = Vector2(0, -grid.size.y*50/2)
	$PetrifyZone.scale = Vector2((grid.petrify_range.y - grid.petrify_range.x)*50, grid.size.y*50)
