extends Bullet

@export var bleeding_scene: PackedScene
@onready var demage = 	$HitBox.hitbox_damage

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1
	await get_tree().create_timer(20.0).timeout
	queue_free()

func _on_body_entered(body: Node) -> void:
	if is_instance_of(body, Player): #Checking for player
		var player = body as Player
		player.create_wound(self)
		var bleeding: Bleeding = bleeding_scene.instantiate()
		bleeding.apply(player)
		bleeding.rotation = collision_rot
		
		
		
	call_deferred("set_freeze_enabled", true)
	call_deferred("reparent", body, true)
	rotation = collision_rot
	await get_tree().create_timer(0.75).timeout
	if $CollisionShape2D != null:
		$CollisionShape2D.queue_free()
	if $HitBox != null: 
		$HitBox.queue_free()
