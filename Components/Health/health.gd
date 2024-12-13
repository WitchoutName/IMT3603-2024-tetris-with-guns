class_name Health
extends Node

signal death
signal health_changed(damage: float)

@export var max_health: int = 100
var invunerability: bool = false 

@export var health: float = max_health
@export var health_bar: ProgressBar

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
	_health_changed()

#Sets max_health to a new value
func set_max_health(new_value: int):
	max_health = new_value

@rpc("any_peer", "call_local")
func _take_demage_logic(demage: float):
	if not multiplayer.is_server(): return
	if not invunerability:
		health -= demage
	_health_changed()
	
	if health <= 0: #Health 0 or bellow means death
		emit_signal("death")	

#Handles damage
func take_damage(demage: float):
	_take_demage_logic.rpc_id(1, demage)
	_health_changed()


#Healing that will not allow to go over max_health
func heal_up_to_max_health(healing: int):
	if healing + health > max_health:
		health = max_health
	else:
		health += healing
	
	_health_changed()

#Healing that will allow healing over max_health
func heal_over_max_health(healing: int):
	health += healing
	_health_changed()
	
func _health_changed():
	if multiplayer.is_server():
		health_bar.value = health
		emit_signal("health_changed", health)


func _on_multiplayer_synchronizer_synchronized() -> void:
	health_bar.value = health
	emit_signal("health_changed", health)
	if health <= 0: #Health 0 or bellow means death
		emit_signal("death")	
