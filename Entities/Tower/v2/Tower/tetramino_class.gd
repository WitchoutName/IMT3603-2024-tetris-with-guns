
class_name TetraminoClass

static var shape_i_rotations = [
	[
		[0, 1, 0, 0],
		[0, 1, 0, 0],
		[0, 1, 0, 0],
		[0, 1, 0, 0],
	],
	[
		[0, 0, 0, 0],
		[1, 1, 1, 1],
		[0, 0, 0, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 1, 0, 0],
		[0, 1, 0, 0],
		[0, 1, 0, 0],
		[0, 1, 0, 0],
	],
	[
		[0, 0, 0, 0],
		[1, 1, 1, 1],
		[0, 0, 0, 0],
		[0, 0, 0, 0],
	]
];

static var shape_j_rotations = [
	[
		[0, 1, 0, 0],
		[0, 1, 0, 0],
		[1, 1, 0, 0],
		[0, 0, 0, 0],
	],
	[
		[1, 0, 0, 0],
		[1, 1, 1, 0],
		[0, 0, 0, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 1, 1, 0],
		[0, 1, 0, 0],
		[0, 1, 0, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 0, 0, 0],
		[1, 1, 1, 0],
		[0, 0, 1, 0],
		[0, 0, 0, 0],
	],
];

static var shape_l_rotations = [
	[
		[0, 1, 0, 0],
		[0, 1, 0, 0],
		[0, 1, 1, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 0, 0, 0],
		[1, 1, 1, 0],
		[1, 0, 0, 0],
		[0, 0, 0, 0],
	],
	[
		[1, 1, 0, 0],
		[0, 1, 0, 0],
		[0, 1, 0, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 0, 1, 0],
		[1, 1, 1, 0],
		[0, 0, 0, 0],
		[0, 0, 0, 0],
	],
];

static var shape_o_rotations = [
	[
		[0, 0, 0, 0],
		[0, 1, 1, 0],
		[0, 1, 1, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 0, 0, 0],
		[0, 1, 1, 0],
		[0, 1, 1, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 0, 0, 0],
		[0, 1, 1, 0],
		[0, 1, 1, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 0, 0, 0],
		[0, 1, 1, 0],
		[0, 1, 1, 0],
		[0, 0, 0, 0],
	],
];

static var shape_s_rotations = [
	[
		[0, 1, 1, 0],
		[1, 1, 0, 0],
		[0, 0, 0, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 1, 0, 0],
		[0, 1, 1, 0],
		[0, 0, 1, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 0, 0, 0],
		[0, 1, 1, 0],
		[1, 1, 0, 0],
		[0, 0, 0, 0],
	],
	[
		[1, 1, 0, 0],
		[1, 1, 0, 0],
		[0, 1, 0, 0],
		[0, 0, 0, 0],
	],
];

static var shape_t_rotations = [
	[
		[0, 0, 0, 0],
		[1, 1, 1, 0],
		[0, 1, 0, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 1, 0, 0],
		[1, 1, 0, 0],
		[0, 1, 0, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 1, 0, 0],
		[1, 1, 1, 0],
		[0, 0, 0, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 1, 0, 0],
		[0, 1, 1, 0],
		[0, 1, 0, 0],
		[0, 0, 0, 0],
	],
];

static var shape_z_rotations = [
	[
		[1, 1, 0, 0],
		[0, 1, 1, 0],
		[0, 0, 0, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 0, 1, 0],
		[0, 1, 1, 0],
		[0, 1, 0, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 0, 0, 0],
		[1, 1, 0, 0],
		[0, 1, 1, 0],
		[0, 0, 0, 0],
	],
	[
		[0, 1, 0, 0],
		[1, 1, 0, 0],
		[1, 0, 0, 0],
		[0, 0, 0, 0],
	],
];

enum PIECE_SHAPE { I, J, L, O, S, T, Z }

static var shape_matrices = {
	PIECE_SHAPE.I: shape_i_rotations.map(transpose_matrix),
	PIECE_SHAPE.J: shape_j_rotations.map(transpose_matrix),
	PIECE_SHAPE.L: shape_l_rotations.map(transpose_matrix),
	PIECE_SHAPE.O: shape_o_rotations.map(transpose_matrix),
	PIECE_SHAPE.S: shape_s_rotations.map(transpose_matrix),
	PIECE_SHAPE.T: shape_t_rotations.map(transpose_matrix),
	PIECE_SHAPE.Z: shape_z_rotations.map(transpose_matrix)
}

static func transpose_matrix(matrix: Array) -> Array:
	var transposed = []  # Initialize the transposed matrix
	
	# Check if the input matrix is not empty
	if matrix.size() == 0:
		return transposed  # Return empty if the original matrix is empty

	var row_count = matrix.size()  # Number of rows in the original matrix
	var col_count = matrix[0].size()  # Number of columns in the original matrix

	# Create an empty transposed matrix with the right dimensions
	for x in range(col_count):
		transposed.append([])  # Add a new row for each column in the original matrix

	# Fill the transposed matrix
	for y in range(row_count):
		for x in range(col_count):
			transposed[x].append(matrix[y][x])  # Swap rows and columns

	return transposed

var position: Vector2
var rotation: int
var pieces_above: Array[Tetramino2]
var pieces_below: Array[Tetramino2]
