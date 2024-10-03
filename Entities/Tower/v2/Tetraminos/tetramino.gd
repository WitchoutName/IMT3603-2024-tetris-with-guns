extends StaticBody2D
class_name Tetramino2

@export var shape: TetraminoClass.PIECE_SHAPE
var matrix: Array
var data: TetraminoClass
var is_petrified: bool = false:
	set = _set__is_petrified
var console_color: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	matrix = TetraminoClass.shape_matrices[shape]
	data = TetraminoClass.new()
	data.rotation = 0
	data.position = Vector2(0, 0)
	console_color = ["#", "@", "%", "W", "$", "&", "E"].pick_random()

func sync(grid_size: Vector2):
	position.x = data.position.x * 50 - grid_size.x/2 * 50 + 75
	position.y = - (grid_size.y - data.position.y) * 50 + 75
	rotation = data.rotation * PI/2


func _set__is_petrified(value: bool):
	is_petrified = value
	var material = preload("res://Shaders/GrayScale/GrayScaleMaterial.tres")
	$Sprite2D.material = material if value else null
