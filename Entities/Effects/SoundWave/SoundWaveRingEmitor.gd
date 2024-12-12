extends Node2D


@export var ring_scene: PackedScene
func _on_timer_timeout() -> void:
	add_child(ring_scene.instantiate())
