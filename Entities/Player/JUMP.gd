extends "state.gd"

func update(delta):
	player_movement()
	Player.gravity(delta)
	if Player.velocity.y>0:
		return STATES.FALL
	if Player.dash_input and Player.can_dash:
		return STATES.DASH
	if Player.get_next_to_wall() != Vector2.ZERO:
		return STATES.SLIDE
	return null

func enter_state():
	Player.velocity.y = Player.JUMP_VELOCITY if Player.is_on_floor() else Player.JUMP_VELOCITY*0.9
	Player.velocity.x += 310 * -Player.get_next_to_wall().x
	#Player.velocity.x += 310 * (1 if Player.is_only_side_touching_feet() else -1) * Player.get_next_to_wall().x
