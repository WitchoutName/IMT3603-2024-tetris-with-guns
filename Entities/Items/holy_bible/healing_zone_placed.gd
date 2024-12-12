extends Node2D

var players: Array[Player] = []

var time_counter = 0.0 
var heal_interval = 1.0
var ticks  = 0 #number of healing ticks passed

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()

func _process(delta):
	if ticks == 15: #Deleting after 15 seconds
		queue_free()
	
	time_counter += delta
	
	#Every second
	if time_counter >= heal_interval:
		for player in players:
			if player != null && player.health.has_method("heal_up_to_max_health"):
				print("I am healing")
				player.health.heal_up_to_max_health(5)
			
		time_counter -= heal_interval
		ticks += 1

func _on_area_2d_body_entered(body):
	if body.is_in_group("players"):
		players.append(body)


func _on_area_2d_body_exited(body):
	if body.is_in_group("players"):
		players.erase(body)
