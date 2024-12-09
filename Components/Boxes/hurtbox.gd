class_name HurtBox
extends Area2D

signal hurtbox_hit(damage: int)

@export var health: Health #Health will need to be assigned

func _ready():
	connect("area_entered", _on_area_entered) #Binding our signal

func _on_area_entered(hitbox: Area2D):
	if not is_multiplayer_authority(): return
	if is_instance_of(hitbox, HitBox):
		health.take_damage(hitbox.get_damage())
		hurtbox_hit.emit(hitbox.get_damage())
