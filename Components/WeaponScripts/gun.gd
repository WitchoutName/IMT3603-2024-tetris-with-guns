extends Node2D
class_name Gun

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
var recoilIncrement: float
var currentRecoil = 0.0


#Equip handling
@onready var interaction_area: InteractionArea = $InteractionArea
var active = false
var player
var start_orientation

func _init() -> void:
	bulletSpeed = 1000
	bps = 5
	bulletDamage = 30
	bulletSpread = 0.01
	timeUntilFire = 0
	maxMag = 7
	currentMag = maxMag
	reloadTime = 1
	maxRecoil = 20.0
	recoilIncrement = maxRecoil * 0.2
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fireRate = 1.0 / bps
	interaction_area.interact = Callable(self, "_on_interact")
	start_orientation = rotation
	_init()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("drop"):
		_drop()
	
	if active:
		look_at(get_global_mouse_position())
		
	
		if get_global_mouse_position().x < position.x:
			scale.y = -1
			rotation += deg_to_rad(currentRecoil)
		elif get_global_mouse_position().x > position.x:
			scale.y = 1
			rotation -= deg_to_rad(currentRecoil)
		
		shoot(delta)
	
		if Input.is_action_just_pressed("reload") or (Input.is_action_just_pressed("click") and currentMag == 0):
			reload()
	else:
		pass
	
func _physics_process(delta: float) -> void:
	if not $AnimatedSprite2D.is_playing():
		currentRecoil = clamp(currentRecoil - recoilIncrement, 0.0, maxRecoil)
		

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
		
		get_tree().root.add_child(bullet)
		bullet.rotation = $Barrel.global_rotation + randf_range(-bulletSpread,bulletSpread)
		bullet.position = $Barrel.global_position
		bullet.linear_velocity = bullet.transform.x * bulletSpeed
		
		
		$AnimatedSprite2D.play("Fire")
		get_tree().root.add_child(casing)
		casing.rotation = $Eject.global_rotation + randf_range(-0.25, 0)
		casing.position = $Eject.global_position
		casing.linear_velocity = casing.transform.y * -150
		timeUntilFire = 0
		currentMag -= 1
		currentRecoil = clamp(currentRecoil + recoilIncrement, 0.0, maxRecoil)
	else:
		timeUntilFire += delta

#On player interaction
func _on_interact(interacted_player: Player):
	player = interacted_player
	if player.equiped_gun: #If the player already has a gun
		await player.equiped_gun._drop() #Dropping it, so that the current can be picked up
	player.health.connect("death", Callable(self, "_drop")) #Connecting drop to death signal
	active = true
	player.equip_gun(self)
	interaction_area.enabled = false 
	interaction_area.force_remove() #We have to force remove it from the manager

#Handles the weapon drop
func _drop():
	rotation = start_orientation
	active = false
	#Disconnecting from death signal
	if player && player.health.is_connected("death", Callable(self, "_respawn_player")):
			player.health.disconnect("death", Callable(self, "_respawn_player"))
	if player:
		player.unequip_gun()
	if player && player.spawned: #If the player is spawned we make the gun interactble again 
		interaction_area.force_add()
	player = null
	interaction_area.enabled = true
