extends Melee

@onready var shieldbox = $ShieldBox
@onready var sprite = $Sprite2D

func _process(delta):
	if active:
		var mouse_pos = get_global_mouse_position()
		look_at(mouse_pos)
		
		var direction = (mouse_pos - player.global_position).normalized()


func _on_interact(interacted_player: Player):
	super._on_interact(interacted_player)
	shieldbox.monitorable = true
	shieldbox.monitoring = true
	sprite.position.x += 45
	
func _drop():
	super._drop()
	shieldbox.monitorable = false
	shieldbox.monitoring = false
	sprite.position.x -= 45


func _on_shield_box_body_entered(body):
	print("HALO KTOŚ JEST WE MNIE AAAAA")
