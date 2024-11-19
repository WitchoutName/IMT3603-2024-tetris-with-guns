extends Node2D
class_name Gun

@export var bulletScene = load("res://Entities/Guns/bullet.tscn")
@export var casingScene = load("res://Entities/Guns/casing.tscn")

@export var bulletSpeed = 1000

@export var bps = 5.0
var fireRate: float
var timeSinceFired: float = 0

@export var bulletDamage: int
@export var bulletSpread = 0.01

@export var magSize = 7
@export var ammoReserve: int
var currentAmmo: int


@export var reloadInterval = 1.0
var isReloading = false
var reloadTimer: Timer = Timer.new()

@export var destructionInterval = 5
var destructionTimer: Timer = Timer.new()

@export var maxRecoil = 20.0
var recoilIncrement: float
var currentRecoil = 0.0

@export var bulletAmount = 1
@export_range(0,360) var arc: float = 0

@export var fullAuto = false



#Equip handling
@onready var interaction_area: InteractionArea = $InteractionArea
var active = false
var player: Player
var start_orientation
var fire_mode = "click"

func _init() -> void:
	fireRate = 1.0/bps
	currentAmmo = magSize
	ammoReserve -= magSize
	recoilIncrement = maxRecoil * 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fireRate = 1.0 / bps
	interaction_area.interact = Callable(self, "_on_interact")
	start_orientation = rotation
	interaction_area.interact = Callable(self, "_on_interact")
	start_orientation = rotation
	add_child(destructionTimer)
	add_child(reloadTimer)
	destructionTimer.timeout.connect(_on_destruction_timer_timeout)
	reloadTimer.timeout.connect(_on_reload_timer_timeout)
	_init()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isReloading: _reaload_animation()
	
	if not is_multiplayer_authority(): return
	if active:
		look_at(get_global_mouse_position())
		scale.y = 1 if get_global_mouse_position().x > self.global_position.x else -1
	
		if get_global_mouse_position().x < position.x:
			scale.y = -1
			rotation += deg_to_rad(currentRecoil)
			
		elif get_global_mouse_position().x > position.x:
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
		shoot.rpc_id(1, delta)
	else: timeSinceFired += delta

func semiFire(delta):
	if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed(fire_mode) and timeSinceFired > fireRate and currentAmmo > 0 and !isReloading:
		shoot.rpc_id(1, delta)
	else: timeSinceFired += delta


func easeInCirc(t):
	return 1 - sqrt(1 - t * t)

func _reaload_animation():
	var percentage = 1 - (reloadTimer.time_left / float(reloadInterval))
	self.scale.x = easeInCirc(percentage)/2 +0.5
	

@rpc("any_peer", "call_local")
func shoot(delta):
	
	var bullet
	var casing = casingScene.instantiate()
	if $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.stop()
		
	for i in bulletAmount:
		bullet = bulletScene.instantiate()
		GameManager.map.bullet_group.add_child(bullet, true)
			
		bullet.set_multiplayer_authority(multiplayer.get_unique_id())
			
			
		if bulletAmount == 1:
			bullet.rotation = global_rotation + (randf_range(-bulletSpread, bulletSpread))
				
		else:
			var arcToRad = deg_to_rad(arc)
			var increment = arcToRad / (bulletAmount - 1)
			bullet.rotation = (global_rotation + increment * i - arcToRad / 2)
			
		bullet.position = $Barrel.global_position
		
		bullet.linear_velocity = bullet.transform.x * bulletSpeed

		bullet.hitbox.set_damage(bulletDamage)

			

		
		
	$AnimatedSprite2D.play("Fire")
	
	get_tree().root.add_child(casing)
	casing.rotation = $Eject.global_rotation + randf_range(-0.25, 0)
	casing.position = $Eject.global_position
	casing.linear_velocity = casing.transform.y * -150
	timeSinceFired = 0
	currentAmmo -= 1
	currentRecoil = clamp(currentRecoil + recoilIncrement, 0.0, maxRecoil)

	
	

func change_parent(location: Node2D = null):
	if location:
		reparent(location)
		position = Vector2.ZERO
	else:
		var root = get_tree().root
		reparent(GameManager.map.item_group)


#On player interaction
func _on_interact(interacted_player: Player):
	destructionTimer.stop()
	if GameManager.my_player.player_peer.id == 1:
		print("host setting multiplayer authority", interacted_player.player_peer.id)
	set_multiplayer_authority(interacted_player.player_peer.id)
	#player = GameManager._players[player_id].entity
	player = interacted_player
	fire_mode = player.inventory.get_fire_mode() #Getting which fire mode to use
	if !fire_mode: #If null returned - slot 3 selected, weapon is not equiped
		fire_mode = "click1"
		return
	if not player.health.is_connected("death", call_drop):
		player.health.connect("death", call_drop) #Connecting drop to death signal
	active = true
	player.inventory.equip_item(self)
	interaction_area.enabled = false 
	interaction_area.force_remove() #We have to force remove it from the manager


func call_drop():
	_drop.rpc()

#Handles the weapon drop
@rpc("authority", "call_local")
func _drop():
	change_parent()
	rotation = start_orientation
	scale = Vector2.ONE
	active = false
	#Disconnecting from death signal
	if player && player.health.is_connected("death", call_drop):
			player.health.disconnect("death", call_drop)
	#if player && player.spawned: #If the player is spawned we make the gun interactble again 
		#interaction_area.force_add()
	player = null
	interaction_area.enabled = true
	
	if isReloading:
		reloadTimer.stop()
		scale.x = 1
		isReloading = false
	
	destructionTimer.start(destructionInterval)
	set_multiplayer_authority(1)

func _on_reload_timer_timeout():
		isReloading = false
		var ammoToLoad = ammoReserve if ammoReserve < magSize else magSize
		currentAmmo = ammoToLoad
		ammoReserve -= ammoToLoad
		scale.x = 1

func _on_destruction_timer_timeout():
	queue_free()
