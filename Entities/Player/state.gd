extends Node

var STATES: PlayerStates = null
var Player: Player = null
	
func enter_state():
	pass
	
func exit_state():
	pass
func update(delta):
	return null

func player_movement():
	
	if Player.movement_input.x > 0:
		if Player.velocity.x < Player.SPEED:
			Player.velocity.x += Player.SPEED*.45 if Player.is_on_floor() else Player.SPEED*.05
		Player.last_direction = Vector2.RIGHT
	elif Player.movement_input.x < 0:
		if Player.velocity.x > -Player.SPEED:
			Player.velocity.x -= Player.SPEED*.45 if Player.is_on_floor() else Player.SPEED*.05
		Player.last_direction = Vector2.LEFT
	Player.velocity.x *= .6 if Player.is_on_floor() else .95
