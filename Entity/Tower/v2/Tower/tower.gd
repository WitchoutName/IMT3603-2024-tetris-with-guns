extends Node2D
class_name Tower2

@export var active_piece: Tetramino2
@export var petrify_width: int
@export_range(1, 10, 0.1) var fall_speed: float
var grid: GridClass

signal win()

func _ready():
	grid = GridClass.new()
	
	var petrify_zone_bg = Sprite2D.new()
	add_child(petrify_zone_bg)
	var image = Image.new()
	var img_size = Vector2((grid.petrify_range.y - grid.petrify_range.x)*50, grid.size.y*50)
	image.create(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 0, 0))
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	petrify_zone_bg.texture = texture
	var bottom_right = Vector2(grid.petrify_range.x * 50, 0)
	var top_left = bottom_right - img_size
	petrify_zone_bg.position = Vector2(0, 0)
	petrify_zone_bg.scale * 5
	$MoveDownTimer.wait_time = 1 - (fall_speed-1)/10


func _process(delta: float) -> void:
	pass

func ap_insert(piece: Tetramino2):
	active_piece = piece
	grid.attach_piece(piece)

func ap_move_left(): # ap -> active piece
	grid.move_left()
	
func ap_move_right():
	grid.move_right()

func ap_rotate():
	grid.rotate()


func _on_move_down_timer_timeout() -> void:
	if active_piece:
		if not grid.move_down():
			grid.dettach_piece()
			active_piece = null
			if  grid.is_win_state():
				_on_win()
				return
			grid.petrify_complete_row()

func _on_win():
	
	emit_signal(win.get_name())
