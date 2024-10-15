extends Node2D

#Player reference
@export var player: Player
#Using a collision shape to get the correct coordinates for player spawn
@onready var player_spawn_pos = $Coordinates.global_position

func _ready():
	$Label.hide()

#Respawns the player and shows the respawn label
func _respawn_player():
	player.global_position = player_spawn_pos
	var screen = get_viewport().get_visible_rect().size
	#Label does not actually work
	$Label.position = (screen - $Label.size) / 2
	$Label.show()
	await player.respawn()
	$Label.hide()
	

func assign_player(p: Player):
	player = p

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player && !player.health.is_connected("death", Callable(self, "_respawn_player")):
		player.health.connect("death", Callable(self, "_respawn_player"))
