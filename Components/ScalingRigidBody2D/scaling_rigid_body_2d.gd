extends RigidBody2D

#@export var scale: Vector2 = Vector2.ONE:
	#set = _set__scale


func _ready():
	_apply_scale()

func _set(name, value):
	match name:
		"scale":
			scale = value
			_apply_scale()


func _apply_scale():
	# apply my own scale to my children
	for child in get_children():
		if child is Node2D:
			child.scale *= scale

	# reset my own scale
	scale = Vector2.ONE
