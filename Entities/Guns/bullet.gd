extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node) -> void:
	
	if is_instance_of(body, Player):
		queue_free()
	elif is_instance_of(body, Tetramino2):
		queue_free()
	else:
		queue_free()
		
func _on_timeout():
	queue_free()
