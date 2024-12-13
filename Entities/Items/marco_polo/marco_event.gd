extends Control

var time_to_complete = 5
var player: Player

@onready var P = $P
@onready var O1 = $O1
@onready var L = $L
@onready var O2 = $O2

var complete = {
	'P': false, 
	'O1': false, 
	'L': false, 
	'O2': false
}

# Called when the node enters the scene tree for the first time.
func _ready():
	player = GameManager.my_player
	if player:
		player.health.connect("death", Callable(self, "_on_player_death"))
		get_tree().create_timer(time_to_complete).connect("timeout", Callable(self, "_on_time_end"))
		player.can_suicide = false
		P.modulate.a = 0.5
		O1.modulate.a = 0.5
		L.modulate.a = 0.5
		O2.modulate.a = 0.5
	else:
		queue_free()

func _input(event):
	if event is not InputEventKey:
		return
	
	if !complete['P'] && event.keycode == KEY_P && event.pressed:
		complete['P'] = true
		P.modulate.a = 1.0
	
	elif complete['P'] && !complete['O1'] && event.keycode == KEY_O && event.pressed:
		complete['O1'] = true
		O1.modulate.a = 1.0
	
	elif complete['O1'] && !complete['L'] && event.keycode == KEY_L && event.pressed:
		complete['L'] = true
		L.modulate.a = 1.0
	
	elif complete['L'] && !complete['O2'] && event.keycode == KEY_O && event.pressed:
		complete['O2'] = true
		O2.modulate.a = 1.0
		player.can_suicide = true
		queue_free()

func _on_player_death():
	player.can_suicide = true
	queue_free()

func _on_time_end():
	player.inventory.delete_inventory()
	player.can_suicide = true
	queue_free()
