class_name InteractionArea
extends Area2D

#IMPORTANT: Needs to collide with the player, i.e. mask sat to player

@export var action_name: String = "Interact"
@export var interaction_group: int = 0
@export var enabled: bool = true

#Function that is to be called upon interaction, needs to be defined in assigned parent node
var interact: Callable = func(player):
	pass


func _on_body_entered(body):
	if enabled and is_instance_of(body, Player): #Checking for player
		InteractionManager.add_area(self)


func _on_body_exited(body):
	if is_instance_of(body, Player): #Checking for player
		InteractionManager.remove_area(self)
