extends Bullet

@export var damage = 100
var overlapping = []

func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	$ExplosionAni.hide()
	await get_tree().create_timer(1.0).timeout
	explode()
	
func _process(delta):
	$ExplosionAni.global_rotation = 0.0
	
func _on_body_entered(Node):
	explode()
	
func explode():
	for body in overlapping:
		if body.is_in_group("players"):
			body.health.take_damage(damage)
	#Hiding the granade, showing the explosion
	call_deferred("set_freeze_enabled", true)
	$Sprite2D.hide()
	$ExplosionAni.show()
	$ExplosionAni.play()
	await $ExplosionAni.animation_finished
	queue_free()


func _on_explotion_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		overlapping.append(body)


func _on_explotion_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		overlapping.erase(body)
