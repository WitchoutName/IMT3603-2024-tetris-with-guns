extends "res://Components/EntitySpawner/entity_spawner.gd"


# Called when the node enters the scene tree for the first time.
func init() -> void:
	parent = GameManager.map.tetramino_group
	super.init()
