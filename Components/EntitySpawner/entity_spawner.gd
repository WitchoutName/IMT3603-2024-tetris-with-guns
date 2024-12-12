extends Area2D

@export var weapons: Array[PackedScene]
@export var weaponWeights: Array[int]
@export var items: Array[PackedScene]
@export var itemWeights: Array[int]
@export var interval: float = 10
@export var parent: Node2D
@export var spawn_weapons = true
@export var spawn_items = true

var entities: Array[PackedScene]
var weights: Array[int]

var timer: Timer = Timer.new()
var init_timer: Timer = Timer.new()
var weighted_entities: Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if spawn_weapons:
		entities.append(weapons)
		weights.append(weaponWeights)
	
	if spawn_items:
		entities.append(items)
		weights.append(itemWeights)
	
	print(len(entities))
	for i in range(len(entities)):
		var weight = 1 if len(weights)-1 < i else weights[i]
		for n in range(weight):
			weighted_entities.append(entities[i])
	
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.autostart = true
	timer.one_shot = true
	#timer.start(interval)
	
	add_child(init_timer)
	init_timer.timeout.connect(_on_init_timer_timeout)
	init_timer.one_shot = true
	#init_timer.start(1 if multiplayer.is_server() else 0.5)
	if multiplayer.is_server():
		GameManager.game_started.connect(_on_init_timer_timeout)

@rpc("authority", "call_local")
func init():
	print("[spawner] ready, spawning", multiplayer.is_server(), name, get_multiplayer_authority())
	spawn()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate(delta)

func spawn_logic():
	if not has_overlapping_bodies():
		spawn()

func spawn():
	if multiplayer.is_server():
		var w_index = RandomNumberGenerator.new().randi_range(0, len(weighted_entities)-1)
		var index = entities.find(weighted_entities[w_index])
		var id = RandomNumberGenerator.new().randi_range(100000000, 999999999)	
		_sync_spawn.rpc(index, id)
			

@rpc("authority", "call_local")
func _sync_spawn(index: int, id: int):
	if parent:
		var instance: Node2D = entities[index].instantiate()
		instance.name = instance.name+"_"+str(id)
		parent.add_child(instance)
		instance.global_position = global_position
		if multiplayer.is_server():
			instance.connect("picked_up", func(): timer.start(interval))
	else: 
		push_error("No parent")


func _on_timer_timeout():
	spawn_logic()
	#timer.start(interval)

func _on_init_timer_timeout():
	init.rpc()
	
