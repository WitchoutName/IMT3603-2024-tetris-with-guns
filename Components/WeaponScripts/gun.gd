extends Node2D

var bulletScene = load("res://Entities/Guns/bullet.tscn")
var casingScene = load("res://Entities/Guns/casing.tscn")
var bulletSpeed: int
var bps: int
var bulletDamage: int
var bulletSpread: float
var fireRate: float
var timeUntilFire = 0
var maxMag: int
var currentMag = maxMag
var reloadTime: int
var isReloading = false
var maxRecoil: float
var currentRecoil = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fireRate = 1.0 / bps
	_init()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	look_at(get_global_mouse_position())

	
	if get_global_mouse_position().x < position.x:
		scale.y = -1
	elif get_global_mouse_position().x > position.x:
		scale.y = 1
	
	shoot(delta)
	
	if Input.is_action_just_pressed("reload") or (Input.is_action_just_pressed("click") and currentMag == 0):
		reload()
	

func _init() -> void:
	bulletSpeed = 1000
	bps = 5
	bulletDamage = 30
	bulletSpread = 0.1
	timeUntilFire = 0
	maxMag = 7
	currentMag = maxMag
	reloadTime = 1
	maxRecoil = 10.0

func reload():
	if !isReloading:
		
		isReloading = true
		await get_tree().create_timer(reloadTime).timeout
		isReloading = false
		currentMag = maxMag
		

func shoot(delta):
	
	if Input.is_action_just_pressed("click") and timeUntilFire > fireRate and currentMag > 0 and !isReloading:
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
		currentMag -= 1
		currentRecoil = clamp(currentRecoil + (maxRecoil * 0.1), 0.0, maxRecoil)
	else:
		timeUntilFire += delta
