extends Node2D
class_name Effect

@export var despawn_interval: float = 20
var player: Player

func _ready() -> void:
	await get_tree().create_timer(despawn_interval).timeout
	remove()

func apply(_player: Player):
	player = _player
	
func remove():
	pass
