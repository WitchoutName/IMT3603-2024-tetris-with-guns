extends Node2D
class_name Gun

@export var bulletScene = load("res://Entities/Guns/bullet.tscn")
@export var casingScene = load("res://Entities/Guns/casing.tscn")

@export var bulletSpeed = 1000

@export var bps = 5.0
var fireRate: float
var timeUntilFire = 0

@export var bulletDamage: int
@export var bulletSpread = 0.01

@export var maxMag = 7
var currentMag: int

@export var reloadTime = 1.0
var isReloading = false

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
	currentMag = maxMag
	recoilIncrement = maxRecoil * 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fireRate = 1.0 / bps
	interaction_area.interact = Callable(self, "_on_interact")
	start_orientation = rotation
	interaction_area.interact = Callable(self, "_on_interact")
	start_orientation = rotation
	_init()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		look_at(get_global_mouse_position())
		
	
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
		
	
		if Input.is_action_just_pressed("reload") or (Input.is_action_just_pressed(fire_mode) and currentMag == 0):
			reload()
	else:
		pass
		if Input.is_action_just_pressed("reload") or (Input.is_action_just_pressed(fire_mode) and currentMag == 0):
			reload()
	
func _physics_process(delta: float) -> void:
	if not $AnimatedSprite2D.is_playing():
		currentRecoil = clamp(currentRecoil - recoilIncrement, 0.0, maxRecoil)
		

func reload():
	if !isReloading:
		
		isReloading = true
		await get_tree().create_timer(reloadTime).timeout
		isReloading = false
		currentMag = maxMag
		
func autoFire(delta):
	if Input.is_action_pressed(fire_mode):
				shoot(delta)
	
func semiFire(delta):
	if Input.is_action_just_pressed(fire_mode):
				shoot(delta)
	else: timeUntilFire += delta
	
func shoot(delta):
	
	if timeUntilFire > fireRate and currentMag > 0 and !isReloading:
		var casing = casingScene.instantiate()
		if $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.stop()
		
		for i in bulletAmount:
			var bullet = bulletScene.instantiate()
			
			
			bullet.set_multiplayer_authority(multiplayer.get_unique_id())
			bullet.set_damage(bulletDamage)
			
			if bulletAmount == 1:
				bullet.rotation = global_rotation
				
			else:
				var arcToRad = deg_to_rad(arc)
				var increment = arcToRad / (bulletAmount - 1)
				bullet.rotation = (global_rotation + increment * i - arcToRad / 2)
				
			
			bullet.position = $Barrel.global_position
			bullet.linear_velocity = bullet.transform.x * bulletSpeed
			
			GameManager.map.bullet_group.add_child(bullet, true)
		
		$AnimatedSprite2D.play("Fire")
		
		get_tree().root.add_child(casing)
		casing.rotation = $Eject.global_rotation + randf_range(-0.25, 0)
		casing.position = $Eject.global_position
		casing.linear_velocity = casing.transform.y * -150
		timeUntilFire = 0
		currentMag -= 1
		currentRecoil = clamp(currentRecoil + recoilIncrement, 0.0, maxRecoil)
	
	else: timeUntilFire += delta
	
#On player interaction
@rpc("any_peer")
#func _on_interact(player_id: int):
func _on_interact(interacted_player: Player):
	set_multiplayer_authority(interacted_player.player_peer.id)
	#player = GameManager._players[player_id].entity
	player = interacted_player
	fire_mode = player.inventory.get_fire_mode() #Getting which fire mode to use
	if !fire_mode: #If null returned - slot 3 selected, weapon is not equiped
		fire_mode = "click1"
		return
	if not player.health.is_connected("death", _drop):
		player.health.connect("death", _drop) #Connecting drop to death signal
	active = true
	player.inventory.equip_item(self)
	interaction_area.enabled = false 
	interaction_area.force_remove() #We have to force remove it from the manager

#Handles the weapon drop
@rpc("authority")
func _drop():
	set_multiplayer_authority(1)
	rotation = start_orientation
	active = false
	#Disconnecting from death signal
	if player && player.health.is_connected("death", _drop):
			player.health.disconnect("death", _drop)
	if player && player.spawned: #If the player is spawned we make the gun interactble again 
		interaction_area.force_add()
	player = null
	interaction_area.enabled = true
