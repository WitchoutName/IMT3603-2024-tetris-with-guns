extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale.x = 0.1
	scale.y = 0.1
	await get_tree().create_timer(2).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scale.x += delta
	scale.y += delta
