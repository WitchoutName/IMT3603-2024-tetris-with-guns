extends Effect

class_name Bleeding

@export var blood_particle: PackedScene
@export var dps: float  # demage per second
@export var particle_speed: float = 200
var target: Health


func apply(player: Player):
	super.apply(player)
	position = player.to_local(global_position)
	target = player.health


func _on_timer_timeout() -> void:
	var rng = RandomNumberGenerator.new()
	var random = rng.randi_range(80, 120) / 100
	var particle: RigidBody2D = blood_particle.instantiate()
	GameManager.map.add_child(particle)
	particle.global_position = global_position
	particle.linear_velocity = transform.x * particle_speed * random
	particle.rotation = random
	
	if target and is_multiplayer_authority():
		if not is_multiplayer_authority(): return
		var timer: Timer = $Timer
		target.take_damage(dps * timer.wait_time)
	
