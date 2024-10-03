extends Node

@export 	var tower: Tower2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if tower.active_piece:
		if Input.is_action_just_pressed("tower_move_left"):
			tower.ap_move_left()
		if Input.is_action_just_pressed("tower_move_right"):
			tower.ap_move_right()
		if Input.is_action_just_pressed("tower_rotate"):
			tower.ap_rotate()
