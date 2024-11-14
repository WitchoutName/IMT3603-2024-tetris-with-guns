extends Node2D
class_name Gun

@export var bulletScene: PackedScene = load("res://Entities/Guns/bullet.tscn")
@export var casingScene: PackedScene = load("res://Entities/Guns/casing.tscn")
@export var bulletSpeed: int
@export var bps: int
@export var bulletDamage: int
@export var bulletSpread: float
@export var fireRate: float
@export var ammo_reserve: int
@export var mag_size: int
@export var ammo_in_mag = mag_size
@export var reloadInterval: float
@export var isReloading = false
@export var maxRecoil: float
@export var currentRecoil = 0.0
@export var destructionInterval: float = 5

var reload_timer: Timer = Timer.new()
var destruction_timer: Timer = Timer.new()
var timeSinceFired: float = 0

#Equip handling
@onready var interaction_area: InteractionArea = $InteractionArea
var active = false
var player: Player
var start_orientation
var fire_mode = "click"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fireRate = 1.0 / bps
	interaction_area.interact = Callable(self, "_on_interact")
	start_orientation = rotation
	interaction_area.interact = Callable(self, "_on_interact")
	start_orientation = rotation
	add_child(destruction_timer)
	add_child(reload_timer)
	destruction_timer.timeout.connect(_on_destruction_timer_timeout)
	reload_timer.timeout.connect(_on_reload_timer_timeout)
	_init()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isReloading: _reaload_animation()
	
	if not is_multiplayer_authority(): return
	if active:
		look_at(get_global_mouse_position())
		scale.y = 1 if get_global_mouse_position().x > self.global_position.x else -1
		shooting_logic(delta)
	
		if Input.is_action_just_pressed("reload") or (Input.is_action_just_pressed(fire_mode) and ammo_in_mag == 0):
			if ammo_reserve > 0:
				reload()
			else:
				var material = preload("res://Shaders/GrayScale/GrayScaleMaterial.tres")
				$AnimatedSprite2D.material = material

func _init() -> void:
	ammo_in_mag = mag_size
	ammo_reserve -= mag_size

func reload():
	if !isReloading:
		isReloading = true
		reload_timer.start(reloadInterval)

func easeInCirc(t):
	return 1 - sqrt(1 - t * t)

func _reaload_animation():
	var percentage = 1 - (reload_timer.time_left / float(reloadInterval))
	self.scale.x = easeInCirc(percentage)/2 +0.5
	

@rpc("any_peer", "call_local")
func shoot():
		var bullet = bulletScene.instantiate()
		var casing = casingScene.instantiate()
		if $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.stop()
		
		bullet.set_multiplayer_authority(multiplayer.get_unique_id())
		GameManager.map.bullet_group.add_child(bullet, true)
		bullet.rotation = $Barrel.global_rotation + randf_range(-bulletSpread,bulletSpread)
		bullet.position = $Barrel.global_position
		bullet.linear_velocity = bullet.transform.x * bulletSpeed
		bullet.hitbox.set_damage(bulletDamage)
		
		$AnimatedSprite2D.play("Fire")
		get_tree().root.add_child(casing)
		casing.rotation = $Eject.global_rotation + randf_range(-0.25, 0)
		casing.position = $Eject.global_position
		casing.linear_velocity = casing.transform.y * -150
		timeSinceFired = 0
		ammo_in_mag -= 1
		currentRecoil = clamp(currentRecoil + (maxRecoil * 0.1), 0.0, maxRecoil)


func shooting_logic(delta):
	if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed(fire_mode) and timeSinceFired > fireRate and ammo_in_mag > 0 and !isReloading:
		shoot.rpc_id(1)
	else:
		timeSinceFired += delta

func change_parent(location: Node2D = null):
	if location:
		reparent(location)
		position = Vector2.ZERO
	else:
		var root = get_tree().root
		reparent(GameManager.map.item_group)


#On player interaction
func _on_interact(interacted_player: Player):
	destruction_timer.stop()
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
		reload_timer.stop()
		scale.x = 1
		isReloading = false
	
	destruction_timer.start(destructionInterval)
	set_multiplayer_authority(1)

func _on_reload_timer_timeout():
		isReloading = false
		var ammo_to_load = ammo_reserve if ammo_reserve < mag_size else mag_size
		ammo_in_mag = ammo_to_load
		ammo_reserve -= ammo_to_load
		scale.x = 1

func _on_destruction_timer_timeout():
	queue_free()
