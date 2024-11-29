extends BaseItem
class_name Gun

@export var bulletScene = load("res://Entities/Guns/bullet.tscn")
@export var casingScene = load("res://Entities/Guns/casing.tscn")

@export var bulletSpeed = 1000

@export var bps = 5.0
var fireRate: float
var timeSinceFired: float = 0

@export var bulletDamage: int
@export var bulletSpread = 0.01

@export var magSize: int
@export var ammoReserve: int
var currentAmmo: int


@export var reloadInterval = 1.0
var isReloading = false
var reloadTimer: Timer = Timer.new()


@export var maxRecoil = 20.0
var recoilIncrement: float
var currentRecoil = 0.0

@export var bulletAmount = 1
@export_range(0,360) var arc: float = 0

@export var fullAuto = false


func init() -> void:
	fireRate = 1.0/bps
	if not is_dupe:
		currentAmmo = magSize
		#ammoReserve -= magSize
		recoilIncrement = maxRecoil * 0.2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(reloadTimer)
	reloadTimer.one_shot = true
	reloadTimer.timeout.connect(_on_reload_timer_timeout)
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isReloading: _reaload_animation()
	
	if not is_multiplayer_authority(): return
	if active:
		look_at(get_global_mouse_position())
	
		if get_global_mouse_position().x < global_position.x:
			scale.y = -1
			rotation += deg_to_rad(currentRecoil)
			
		elif get_global_mouse_position().x > global_position.x:
			scale.y = 1
			rotation -= deg_to_rad(currentRecoil)
			
		if fullAuto:
			autoFire(delta)
		else:
			semiFire(delta)
		
	
		if Input.is_action_just_pressed("reload") or (Input.is_action_just_pressed(fire_mode) and currentAmmo <= 0):
			if ammoReserve > 0:
				reload()
			else:
				set_empty.rpc()
	

@rpc("authority", "call_local")
func set_empty():
	var material = preload("res://Shaders/GrayScale/GrayScaleMaterial.tres")
	$AnimatedSprite2D.material = material	
	
func _physics_process(delta: float) -> void:
	if not $AnimatedSprite2D.is_playing():
		currentRecoil = clamp(currentRecoil - recoilIncrement, 0.0, maxRecoil)
		

func reload():
	if !isReloading:
		isReloading = true
		reloadTimer.start(reloadInterval)
		
func autoFire(delta):
	if not is_multiplayer_authority(): return
	if Input.is_action_pressed(fire_mode) and timeSinceFired > fireRate and currentAmmo > 0 and !isReloading:
		shoot.rpc(Time.get_ticks_msec())
	else: timeSinceFired += delta

func semiFire(delta):
	if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed(fire_mode) and timeSinceFired > fireRate and currentAmmo > 0 and !isReloading:
		shoot.rpc(Time.get_ticks_msec())
	else: timeSinceFired += delta


func easeInCirc(t):
	return 1 - sqrt(1 - t * t)

func _reaload_animation():
	var percentage = 1 - (reloadTimer.time_left / float(reloadInterval))
	self.scale.x = easeInCirc(percentage)/2 +0.5
	

@rpc("any_peer", "call_local")
func shoot(seed: int):
	
	var bullet: Node2D
	var casing = casingScene.instantiate()
	if $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.stop()
		
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	for i in bulletAmount:
		bullet = bulletScene.instantiate()
		bullet.set_multiplayer_authority(get_multiplayer_authority())
		GameManager.map.bullet_group.add_child(bullet, true)
		print(bullet.get_path(), multiplayer.is_server(), bullet.get_multiplayer_authority())
		
		var random = rng.randi_range(-100, 100) * bulletSpread / 1000	
		if bulletAmount == 1:
			bullet.rotation = global_rotation + random
		else:
			var arcToRad = deg_to_rad(arc)
			var increment = arcToRad / (bulletAmount - 1) + random	
			bullet.rotation = (global_rotation + increment * i - arcToRad / 2)
			
		bullet.position = $Barrel.global_position
		bullet.linear_velocity = bullet.transform.x * bulletSpeed
		bullet.hitbox.set_damage(bulletDamage)

	$AnimatedSprite2D.play("Fire")
	GameManager.map.add_child(casing)
	casing.rotation = $Eject.global_rotation + randf_range(-0.25, 0)
	casing.position = $Eject.global_position
	casing.linear_velocity = casing.transform.y * -150
	timeSinceFired = 0
	currentAmmo -= 1
	currentRecoil = clamp(currentRecoil + recoilIncrement, 0.0, maxRecoil)

	
func _clone_custom(dupe):
	dupe.ammoReserve = ammoReserve
	dupe.currentAmmo = currentAmmo

func _drop_custom():
	if isReloading:
		reloadTimer.stop()
		scale.x = 1
		isReloading = false



func _on_reload_timer_timeout():
	if not is_multiplayer_authority(): return
	isReloading = false
	var ammoToLoad = ammoReserve if ammoReserve < magSize else magSize
	currentAmmo = ammoToLoad
	ammoReserve -= ammoToLoad
	scale.x = 1
