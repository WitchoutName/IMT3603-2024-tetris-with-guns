extends RigidBody2D

@export var despawn_interval: float = 20
@export var effect_scene: PackedScene
@onready var hitbox: HitBox = $HitBox
var color: Color

@export var BASE_SATURATION: float = 0.68
@export var BASE_VALUE: float = 0.73

func get_random_moduate():
	var rng = RandomNumberGenerator.new()
	var random_hue: float = rng.randf()	
	return Color.from_hsv(random_hue, BASE_SATURATION, BASE_VALUE, 1.0)

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1
	color = get_random_moduate()
	$Sprite2D.modulate = color
	await get_tree().create_timer(despawn_interval).timeout
	queue_free()
	
	
func _on_body_entered(body: Node) -> void:
	if is_instance_of(body, Player): #Checking for player
		var player = body as Player
		var effect: Effect = effect_scene.instantiate()
		effect.color = color
		player.EffectsGroup.add_child(effect)
		effect.apply(player)
		
		queue_free()
