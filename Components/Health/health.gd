class_name Health
extends Node

signal death
signal health_changed(damage: int)

var max_health: int = 100
var invunerability: bool = false 

@onready var health: int = max_health

#Changes the value of invunerability
func toggle_invulnerability():
	invunerability = !invunerability

#Returns current health
func get_current_health() -> int:
	return health

#Returns max_health
func get_max_health() -> int:
	return max_health

#Sets health to a new value
func set_health(new_value: int):
	health = new_value
	emit_signal("health_changed", new_value)

#Sets max_health to a new value
func set_max_health(new_value: int):
	max_health = new_value

#Handles damage
func take_damage(damage: int):
	if invunerability == false:
		health -= damage
	emit_signal("health_changed", -damage)
	
	if health <= 0: #Health 0 or bellow means death
		emit_signal("death")

#Healing that will not allow to go over max_health
func heal_up_to_max_health(healing: int):
	if healing + health > max_health:
		health = max_health
	else:
		health += healing
	
	emit_signal("health_changed", healing)

#Healing that will allow healing over max_health
func heal_over_max_health(healing: int):
	health += healing
	emit_signal("health_changed", healing)
