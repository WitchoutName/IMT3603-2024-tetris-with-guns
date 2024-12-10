extends RigidBody2D

class_name Bullet

@onready var hitbox: HitBox = $HitBox
@onready var raycast: RayCast2D = $RayCast2D
@export var blood_splatter: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1
	await get_tree().create_timer(5.0).timeout
	queue_free()
	
	
var collision_rot: float = 0
func _physics_process(delta: float) -> void:  
	raycast.force_raycast_update()
	if raycast.is_colliding() and collision_rot == 0:
		collision_rot = rotation
		 

func _on_body_entered(body: Node) -> void:
	if is_instance_of(body, Player): #Checking for player
		var player = body as Player
		player.create_wound(self)
	queue_free()


var collision_pos : Vector2 = Vector2(0.0, 0.0)
func _integrate_forces(state : PhysicsDirectBodyState2D) -> void:
	if state.get_contact_count() > 0:
		collision_pos = state.get_contact_local_position(0)
