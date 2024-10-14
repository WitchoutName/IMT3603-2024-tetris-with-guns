extends "state.gd"

func update(delta):
	player_movement()
	Player.gravity(delta)
	if Player.velocity.y>0:
		return STATES.FALL
	if Player.dash_input and Player.can_dash:
		return STATES.DASH
	#if Player.get_next_to_wall() !=0:
		#return STATES.SLIDE
	return null

func enter_state():
	Player.velocity.y = Player.JUMP_VELOCITY
