extends CharacterBody2D

# Define variables for movement
var speed = 200
var jump_force = -400
var gravity = 900

func _physics_process(delta):
	# Handle horizontal movement
	var direction = 0
	if Input.is_action_pressed("ui_right"):
		direction += 1
	if Input.is_action_pressed("ui_left"):
		direction -= 1

	velocity.x = direction * speed

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Handle jumping
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force

	# Move the character
	move_and_slide()
