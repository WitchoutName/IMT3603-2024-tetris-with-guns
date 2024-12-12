extends Node2D

@onready var collider: CollisionPolygon2D = $CollisionPolygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#collider.scale.x = 0
	#collider.scale.y = 0
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		look_at(get_global_mouse_position())
	#collider.scale.x = min(scale.x + delta/10, 1)
	#collider.scale.y = min(scale.y + delta/10, 1)
