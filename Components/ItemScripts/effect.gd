extends Node2D
class_name Effect

@export var is_stackable: bool = true
@export var despawn_interval: float = 20
var player: Player

func _ready() -> void:
	await get_tree().create_timer(despawn_interval).timeout
	remove()

func apply(_player: Player):
	player = _player
	if not is_stackable:
		for effect in player.effects:
			if effect != null and effect.is_class(self.get_class()):
				effect.remove()
	player.effects.append(self)
	player.EffectsGroup.add_child(self)
	
func remove():
	queue_free()
