extends Node2D
class_name PlayerStates

@onready var JUMP = $JUMP
@onready var FALL = $FALL
@onready var IDLE = $IDLE
@onready var MOVE = $MOVE
@onready var DASH = $DASH
@onready var SLIDE = $SLIDE
#@onready var CLIMB = $CLIMB

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass
