class_name HitBox
extends Area2D

@export var hitbox_damage: int = 1 : set = set_damage, get = get_damage

func set_damage(value: int):
	hitbox_damage = value

func get_damage() -> int:
	return hitbox_damage
