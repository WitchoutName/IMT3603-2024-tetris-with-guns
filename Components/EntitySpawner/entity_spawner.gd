extends Area2D

@export var entities: Array[PackedScene]
@export var interval: float = 10
@export var parent: Node2D

var slot: Node2D
var timer: Timer = Timer.new()
var init_timer: Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.autostart = true
	timer.start(interval)
	
	add_child(init_timer)
	init_timer.timeout.connect(_on_init_timer_timeout)
	init_timer.one_shot = true
	init_timer.start(1)

func init():
	print("[spawner] ready, spawning", name, get_multiplayer_authority())
	spawn()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate(delta)

func spawn_logic():
	if not has_overlapping_bodies():
		spawn()

func spawn():
	if multiplayer.is_server():
		var index = RandomNumberGenerator.new().randi_range(0, len(entities)-1)	
		_sync_spawn.rpc(index)
			

@rpc("authority", "call_local")
func _sync_spawn(index: int):
	var instance: Node2D = await entities[index].instantiate()
	parent.add_child(instance)
	instance.global_position = global_position


func _on_timer_timeout():
	spawn_logic()
	timer.start(interval)

func _on_init_timer_timeout():
	init()
