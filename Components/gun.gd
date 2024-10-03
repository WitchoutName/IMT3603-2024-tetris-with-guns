extends Node2D

var bulletScene = load("res://Entities/bullet.tscn")
var casingScene = load("res://Entities/casing.tscn")
@export var bulletSpeed = 1000
@export var bps = 2
@export var bulletDamage = 30
@export var bulletSpread = 0.1
var fireRate: float
@export var timeUntilFire = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fireRate = 1 / bps


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("click") and timeUntilFire > fireRate:
		var bullet = bulletScene.instantiate()
		var casing = casingScene.instantiate()
		if $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.stop()
		
		owner.add_child(bullet)
		bullet.rotation = $Barrel.global_rotation + randf_range(-bulletSpread,bulletSpread)
		bullet.position = $Barrel.global_position
		bullet.linear_velocity = bullet.transform.x * bulletSpeed
		
		
		$AnimatedSprite2D.play("Fire")
		owner.add_child(casing)
		casing.rotation = $Eject.global_rotation + randf_range(-0.25, 0)
		casing.position = $Eject.global_position
		casing.linear_velocity = casing.transform.y * -150
		timeUntilFire = 0
		
		
	
	else:
		timeUntilFire += delta
		
