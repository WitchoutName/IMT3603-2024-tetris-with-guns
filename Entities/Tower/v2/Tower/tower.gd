extends Node2D
class_name Tower2

@export var active_piece: Tetramino2
@export var tower_dimensions: Vector2 = Vector2(10, 20)
@export var petrify_width: int = 6
@export_range(1, 10, 0.1) var fall_speed: float = 7.5
var grid: GridClass
var piece_queue: Array[Tetramino2]

signal win()

func _ready():
	grid = GridClass.new(tower_dimensions, petrify_width)
	_init_bg()
	$MoveDownTimer.wait_time = 1 - (fall_speed-1)/10


func _process(delta: float) -> void:
	pass

func ap_insert(piece: Tetramino2):
	if active_piece or len(piece_queue) > 0:
		piece_queue.append(piece)
	else:
		active_piece = piece
		piece.interaction_area.enabled = false
		grid.attach_piece(piece)

func ap_move_left(): # ap -> active piece
	grid.move_left()
	
func ap_move_right():
	grid.move_right()

func ap_rotate():
	grid.rotate()

func steal(piece: Tetramino2):
	grid.remove_piece(piece)
	piece.tower = null

func _on_move_down_timer_timeout() -> void:
	if active_piece:
		if not grid.move_down():
			grid.dettach_piece()
			active_piece.interaction_area.enabled = true
			if len(piece_queue) > 0:
				active_piece = piece_queue.pop_at(0)
				active_piece.interaction_area.enabled = false
				grid.attach_piece(active_piece)
			else: active_piece = null
			if  grid.is_win_state():
				_on_win()
				return
			grid.petrify_complete_row()

func _on_win():
	
	emit_signal(win.get_name())


func _init_bg():
	
	$PetrifyZone.position = Vector2(0, -grid.size.y*50/2)
	$PetrifyZone.scale = Vector2((grid.petrify_range.y - grid.petrify_range.x)*50, grid.size.y*50)
