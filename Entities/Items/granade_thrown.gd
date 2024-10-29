extends RigidBody2D

@onready var timer: Timer = $Timer
@export var damage = 100

var overlapping = []

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()

func _on_timer_timeout():
	for body in overlapping:
		if body.is_in_group("players"):
			body.health.take_damage(damage)
	queue_free()


func _on_area_2d_body_entered(body):
	if body.is_in_group("players"):
		overlapping.append(body)


func _on_area_2d_body_exited(body):
	if body.is_in_group("players"):
		overlapping.erase(body)
