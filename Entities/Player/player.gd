extends CharacterBody2D
class_name Player

const SPEED = 250.0
const JUMP_VELOCITY = -600.0

var tower: Tower2
var is_controlling_tower: bool = false
var piece_catied: Tetramino2
var move_direction: float

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_direction = 0
	
	if is_controlling_tower: _handle_tower_input()
	else: _handle_move_input()
	
	if move_direction:
		velocity.x = move_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func _handle_move_input():
		# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	move_direction = Input.get_axis("ui_left", "ui_right")

func _handle_tower_input():
	if tower.active_piece:
		if Input.is_action_just_pressed("tower_move_left"):
			tower.ap_move_left()
		if Input.is_action_just_pressed("tower_move_right"):
			tower.ap_move_right()
		if Input.is_action_just_pressed("tower_rotate"):
			tower.ap_rotate()


func _on_health_death():
	queue_free()
	#Further death logic will be implemented here
