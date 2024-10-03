
class_name GridClass

static var DIMENSTIONS: Vector2 = Vector2(10, 20)
static var PETRIFY_WIDTH: int = 6
static var SPAWN_POINT: Vector2 = Vector2(5, 0)
var matrix: Array
var size: Vector2
var petrify_range: Vector2
var active_piece: Tetramino2


func _init(_size: Vector2 = DIMENSTIONS, petrify_width: int = PETRIFY_WIDTH):
	size = _size
	petrify_range = Vector2(size.x/2 - petrify_width/2, size.x/2 + petrify_width/2)
	for x in range(_size.x):
		matrix.append([])
		for y in range(_size.y):
			matrix[x].append(null)

func attach_piece(piece: Tetramino2, position: Vector2 = SPAWN_POINT):
	active_piece = piece
	active_piece.data.position = position
	active_piece.sync(size)

func move_down() -> bool:
	var new_position = active_piece.data.position + Vector2(0, 1)
	if not _is_colliding(active_piece.matrix[active_piece.data.rotation], new_position):
		active_piece.data.position = new_position
		active_piece.sync(size)
		return true
	return false
	
func move_left() -> bool:
	var new_position = active_piece.data.position + Vector2(-1, 0)
	if not _is_colliding(active_piece.matrix[active_piece.data.rotation], new_position):
		active_piece.data.position = new_position
		active_piece.sync(size)
		return true
	return false

func move_right() -> bool:
	var new_position = active_piece.data.position + Vector2(1, 0)
	if not _is_colliding(active_piece.matrix[active_piece.data.rotation], new_position):
		active_piece.data.position = new_position
		active_piece.sync(size)
		return true
	return false

func rotate() -> bool:
	var new_rotation = 0
	match active_piece.shape:
		TetraminoClass.PIECE_SHAPE.I:
			# Looking at the definition of shape_i_rotations, we can observe, 
			# that the 4x4 matrix isn't big enough to hold all 4 rotation of the I shape 
			# rotates 0,1 -> 0, 1, 0, 1, 0, 1, 0, ...		
			new_rotation = (active_piece.data.rotation + 1) % 2 * 3
		TetraminoClass.PIECE_SHAPE.O:
			# Looking at the definition of shape_i_rotations, the shape doesn't change
			pass
		_:
			# rotates 0-3 -> 0, 1, 2, 3, 0, 1, 2, ...
			new_rotation = (active_piece.data.rotation + 1) % 4
		
	if not _is_colliding(active_piece.matrix[new_rotation], active_piece.data.position):
		active_piece.data.rotation = new_rotation
		active_piece.sync(size)
		return true
	return false

func dettach_piece():
	var piece_matrix = active_piece.matrix[active_piece.data.rotation]
	for x in range(piece_matrix.size()):
		for y in range(piece_matrix[x].size()):
			# If the cell is not part of the shape, skip it
			if piece_matrix[x][y] == 0:
				continue
			# Calculate the corresponding position in the grid
			var grid_x = active_piece.data.position.x + x
			var grid_y = active_piece.data.position.y + y
			matrix[grid_x][grid_y] = active_piece
	active_piece = null
	print("---start---")
	print_grid()
	print("----end----")

func _is_colliding(piece_matrix: Array, position: Vector2) -> bool:
	for x in range(piece_matrix.size()):
		for y in range(piece_matrix[x].size()):
			# If the cell is not part of the shape, skip it
			if piece_matrix[x][y] == 0:
				continue
			
			# Calculate the corresponding position in the grid
			var grid_x = position.x + x
			var grid_y = position.y + y
			
			if grid_x < 0 or grid_x >= size.x or grid_y < 0 or grid_y >= size.y:
				return true

			if matrix[grid_x][grid_y] != null:
				return true
	
	# No collision detected
	return false

func print_grid() -> void:
	for y in range(size.y):  # Start from the last row to the first
		var row_string = ""
		for x in range(size.x):  # Iterate through each column in the row
			if matrix[x][y]:
				row_string += matrix[x][y].console_color
			else:
				row_string += " "  # Empty space
		print(row_string + "  ", y)  # Print the constructed row

func get_complete_row() -> int:
	for y in range(size.y-1, -1, -1):
		print("row:", y)
		var is_complete = true
		for x in range(petrify_range.x, petrify_range.y):
			if y > 16: print("p: ", x)
			var piece = matrix[x][y] 
			if piece:
				if not _is_piece_grounded(piece):
					print("Not grounded")
					is_complete = false
			else:
				is_complete = false
		if is_complete: return y
	return -1

func _is_piece_grounded(piece: Tetramino2): # Piece is grounded if at leat one part is above ground or petrified piece
	var piece_matrix = piece.matrix[piece.data.rotation]
	for x in range(piece_matrix.size()):
		for y in range(piece_matrix[x].size()):
			if piece_matrix[x][y] == 0:
				continue
			# Calculate the corresponding position in the grid
			var grid_x = piece.data.position.x + x
			var grid_y = piece.data.position.y + y
			
			if grid_y >= size.y-1:
				print("Grounded on floor")
				return true
			var piece_below = matrix[grid_x][grid_y+1]
			if piece_below and piece_below.is_petrified:
				return true
	return false

func petrify_complete_row():
	var y = get_complete_row()
	if y > -1:
		for x in range(size.x):
			var piece = matrix[x][y]
			if piece:
				if not piece.is_petrified: piece.is_petrified = true


func is_win_state() -> bool:
	for x in range(size.x):
		if matrix[x][0]: return true
	return false
