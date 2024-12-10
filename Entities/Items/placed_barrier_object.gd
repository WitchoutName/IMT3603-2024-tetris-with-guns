extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Health.set_max_health(75)
	$Health.set_health(75)



func _on_health_death():
	queue_free()
