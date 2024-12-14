extends Node2D

var player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	player = get_parent()
	if player is Player:
		if !player.health.invunerability:
			player.health.toggle_invulnerability()
		player.can_shoot = false
		player.can_interact = false
		player.health.connect("death", Callable(self, "_disable"))
		get_tree().create_timer(7.5).connect("timeout", Callable(self, "_disable"))
		rotation = 25
	else:
		queue_free()

func _disable():
	player.health.invunerability = false
	player.can_shoot = true
	player.can_interact = true
	queue_free()
