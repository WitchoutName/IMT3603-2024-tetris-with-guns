extends Melee

@onready var hitbox = $HitBox
@onready var sprite = $Sprite2D
@onready var tipcol = $TipCollision

var fly = false
var fly_vel:Vector2
var gravity = Vector2(0, 500)

func _process(delta):
	if not is_multiplayer_authority(): return
	
	if active && not fly:
		look_at(get_global_mouse_position())
		if Input.is_action_just_pressed(fire_mode):
			_shoot.rpc_id(1)

@rpc("any_peer", "call_local")
func _shoot():
	var direction = (get_global_mouse_position() - global_position).normalized()
	fly_vel = direction * 700
	fly = true
	_active_unequip.rpc()
	hitbox.set_damage(50)
	tipcol.monitoring = true
	tipcol.monitorable = true

func _physics_process(delta):
	if not fly:
		return
	
	fly_vel += gravity * delta
	position += fly_vel * delta
	
	if fly_vel.length() > 0:
		rotation = fly_vel.angle()

func _on_interact(interacted_player: Player):
	super._on_interact(interacted_player)
	#Moving the spear sprite so that it follows the mouse
	sprite.rotation = deg_to_rad(45)
	#Activating hitbox
	hitbox.monitoring = true
	hitbox.monitorable = true

@rpc("authority", "call_local")
func _drop():
	super._drop()
	hitbox.monitoring = false
	hitbox.monitorable = false
	sprite.rotation = deg_to_rad(-45)

func _on_tip_collision_body_entered(body):
	queue_free()
