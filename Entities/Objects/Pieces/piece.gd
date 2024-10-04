extends RigidBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
var picked_up: bool = false
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	interaction_area.interact = Callable(self, "_on_interact") #Assigning interact function
	player = get_tree().get_first_node_in_group("players")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if picked_up && player:
		global_position = player.global_position
		

func _on_interact(_player: Player):
	print("It works!")
	$CollisionShape2D.disabled = true
	picked_up = true
	player = _player
	
	#Awaiting release in order to avoid triggering release
	await wait_for_no_input()
	
	await release()
	$CollisionShape2D.disabled = false
	player = null

func release():
	while true:
		if Input.is_action_just_pressed("interact"): #We wait for interaction again to release
			picked_up = false
			print("released")
			break
		await get_tree().process_frame #Otherwise we wait for next frame (pause)

func wait_for_no_input():
	while Input.is_action_pressed("interact"):
		await get_tree().process_frame
