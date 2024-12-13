extends Effect

@export var overlay_prefab: PackedScene
var overlay: Control
var color: Color


func apply(_player: Player):
	super.apply(_player)
	$Sprite2D.modulate = color
	player.health_bar.hide()
	player.Username.hide()
	if player.player_peer.id == GameManager.my_id:
		var display = GameManager.map.HUD.get_children()[0]
		overlay = overlay_prefab.instantiate()
		display.add_child(overlay)
		overlay.modulate = color
	
func remove():
	player.health_bar.show()
	player.Username.show()
	if overlay != null:
		overlay.queue_free()
		overlay = null
	queue_free()
