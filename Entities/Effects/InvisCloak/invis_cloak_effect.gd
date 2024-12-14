extends Effect

func apply(_player: Player):
	super.apply(_player)
	_player.ASprite.hide()
	_player.Username.hide()
	_player.health_bar.hide()
	_player.invis = true

func remove():
	player.ASprite.show()
	player.Username.show()
	player.health_bar.show()
	player.invis = false
