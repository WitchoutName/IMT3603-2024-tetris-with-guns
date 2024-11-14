extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()
	contact_monitor = true
	max_contacts_reported = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node) -> void:
#	if is_instance_of(body, Player):
#		queue_free()
#	elif is_instance_of(body, Tetramino2):
#		queue_free()
	queue_free()
