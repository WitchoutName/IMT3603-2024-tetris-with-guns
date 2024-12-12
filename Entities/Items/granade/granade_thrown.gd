extends RigidBody2D

@onready var timer: Timer = $Timer
@export var damage = 100

var overlapping = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$ExplosionAni.hide()
	timer.start()

#Does not rotate the explosion animation (looks kinds goofy)
func _process(delta):
	$ExplosionAni.global_rotation = 0.0

func _on_timer_timeout():
	for body in overlapping:
		if body.is_in_group("players"):
			body.health.take_damage(damage)
	#Hiding the granade, showing the explosion
	$Sprite2D.hide()
	$ExplosionAni.show()
	$ExplosionAni.play()

#Getting all overlapping players
func _on_area_2d_body_entered(body):
	print(body)
	if body.is_in_group("players"):
		overlapping.append(body)


func _on_area_2d_body_exited(body):
	if body.is_in_group("players"):
		overlapping.erase(body)

#Upon explosion end we delete the granade node
func _on_explosion_ani_animation_finished():
	queue_free()
