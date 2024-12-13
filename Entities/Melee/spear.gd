extends Melee

@onready var hitbox = $HitBox
@onready var sprite = $Sprite2D
@onready var tipcol = $TipCollision

var fly = false
var fly_vel:Vector2
var gravity = Vector2(0, 500)

func _process(_delta):
	if not is_multiplayer_authority(): return
	
	if active && not fly:
		_look_at.rpc(get_global_mouse_position())
		if Input.is_action_just_pressed(fire_mode):
			_shoot.rpc((get_global_mouse_position() - global_position).normalized())

@rpc("any_peer", "call_local")
func _shoot(direction):
	fly_vel = direction * 700
	fly = true
	player.inventory.clear_slot_right()
	_active_unequip.rpc()
	hitbox.set_damage(70)
	tipcol.monitoring = true
	tipcol.monitorable = true

func _physics_process(delta):
	if not fly:
		return
	
	fly_vel += gravity * delta
	position += fly_vel * delta
	
	if fly_vel.length() > 0:
		rotation = fly_vel.angle()

func _apply_properties():
	#Moving the spear sprite so that it follows the mouse
	sprite.rotation = deg_to_rad(45)
	#Activating hitbox
	hitbox.monitoring = true
	hitbox.monitorable = true

func _reset_properties():
	hitbox.monitoring = false
	hitbox.monitorable = false
	sprite.rotation = deg_to_rad(-45)

func _on_tip_collision_body_entered(_body):
	queue_free()
