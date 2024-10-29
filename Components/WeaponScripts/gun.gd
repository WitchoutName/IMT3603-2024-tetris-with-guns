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
var player: Player
var start_orientation
var fire_mode = "click"

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
		
		shoot(delta)
		shoot(delta)
	
		if Input.is_action_just_pressed("reload") or (Input.is_action_just_pressed("click") and currentMag == 0):
			reload()
	else:
		pass
		if Input.is_action_just_pressed("reload") or (Input.is_action_just_pressed("click") and currentMag == 0):
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
		

func shoot(delta):
	
	if Input.is_action_just_pressed(fire_mode) and timeUntilFire > fireRate and currentMag > 0 and !isReloading:
		var bullet = bulletScene.instantiate()
		var casing = casingScene.instantiate()
		if $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.stop()
		
		bullet.set_multiplayer_authority(multiplayer.get_unique_id())
		GameManager.map.bullet_group.add_child(bullet, true)
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
