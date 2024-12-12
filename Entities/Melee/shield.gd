extends Melee

@onready var shieldbox = $ShieldBox
@onready var sprite = $Sprite2D

func _ready():
	super._ready()
	$Health.set_max_health(75)

func _process(_delta):
	if active && is_multiplayer_authority():
		var mouse_pos = get_global_mouse_position()
		_look_at.rpc(mouse_pos)

func _apply_properties():
	shieldbox.monitorable = true
	shieldbox.monitoring = true
	sprite.position.x = 45
	
func _reset_properties():
	shieldbox.monitorable = false
	shieldbox.monitoring = false
	sprite.position.x = 0


func _on_shield_box_body_entered(body):
	if body.is_in_group("players"):
		body.health.take_damage(1)
	if body.name == "bullet":
		body.queue_free()

#On shield health deplication
func _on_health_death():
	call_drop()
	$InteractionArea.force_remove()
	queue_free()
