class_name InteractionArea
extends Area2D

#IMPORTANT: Needs to collide with the player, i.e. mask sat to player

@export var action_name: String = "Interact"
@export var interaction_group: int = 0
@export var enabled: bool = true

#Function that is to be called upon interaction, needs to be defined in assigned parent node
var interact: Callable = func(player):
	pass

@rpc("any_peer", "call_local")
func remote_interact(player_id: int):
	if interact.is_valid():
		var player: Player = GameManager._players[player_id].entity
		interact.call(player)


func _on_body_entered(body):
	if enabled and is_instance_of(body, Player): #Checking for player
		if body == GameManager.my_player:
			InteractionManager.add_area(self)


func _on_body_exited(body):
	if is_instance_of(body, Player): #Checking for player
		if body == GameManager.my_player:
			InteractionManager.remove_area(self)

func force_remove():
	InteractionManager.remove_area(self)

func force_add():
	InteractionManager.add_area(self)
