extends Melee

@onready var shieldbox = $ShieldBox
@onready var sprite = $Sprite2D

func _ready():
	super._ready()
	$Health.set_max_health(75)

func _process(delta):
	if active && is_multiplayer_authority():
		var mouse_pos = get_global_mouse_position()
		_look_at.rpc(mouse_pos)
		
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
	if body.is_in_group("players"):
		body.health.take_damage(1)
	if body.name == "bullet":
		print("bullet")
		body.queue_free()


func _on_health_death():
	call_drop()
	$InteractionArea.force_remove()
	queue_free()
