class_name InteractionArea
extends Area2D

#IMPORTANT: Needs to collide with the player, i.e. mask sat to player

@export var action_name: String = "Interact"

#Function that is to be called upon interaction, needs to be defined in assigned parent node
var interact: Callable = func():
	pass


func _on_body_entered(body):
	if body is Player: #Checking for player
		InteractionManager.add_area(self)


func _on_body_exited(body):
	if body is Player: #Checking for player
		InteractionManager.remove_area(self)
