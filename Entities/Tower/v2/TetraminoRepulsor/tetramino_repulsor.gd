extends Area2D

@export var force: Vector2
@export var max_velocity: float
var pieces: Array[Tetramino2]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	for piece in pieces:
		if abs(piece.linear_velocity.x) - piece.linear_velocity.y < max_velocity:
			piece.apply_force(force)
		


func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Tetramino2):
		var piece = body as Tetramino2
		pieces.append(piece)


func _on_body_exited(body: Node2D) -> void:
	if is_instance_of(body, Tetramino2):
		var piece = body as Tetramino2
		pieces.erase(piece)
