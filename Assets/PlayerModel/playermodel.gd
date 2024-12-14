extends Node2D

# Declare references to AnimationPlayer and other necessary nodes.
@onready var animation_player = $AnimationPlayer
@onready var skeleton = $CharacterContainer/Bones/Skeleton2D
@onready var character_container = $CharacterContainer  # Reference to the character container for flipping

# Define movement states
enum {
	IDLE,
	WALK,
	JUMP
}

var current_state = IDLE

func _ready():
	# Initialization if needed
	pass

func _process(delta):
	# Handle player input
	var velocity = Vector2()
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	elif Input.is_action_pressed("move_left"):
		velocity.x -= 1

	if Input.is_action_just_pressed("jump"):
		_jump()

	# Flip character based on direction
	if velocity.x > 0:
		character_container.scale.x = 1  # Face right
	elif velocity.x < 0:
		character_container.scale.x = -1  # Face left

	# Play walk animation if moving horizontally, otherwise idle
	if velocity.length() > 0:
		_walk()
	else:
		_idle()

func _walk():
	if current_state != WALK:
		animation_player.play("Walk")
		current_state = WALK

func _idle():
	if current_state != IDLE:
		animation_player.play("Idle")
		current_state = IDLE

func _jump():
	animation_player.play("Jump")
	current_state = JUMP
