extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
var tower: Tower2 

# Called when the node enters the scene tree for the first time.
func _ready():
	interaction_area.interact = Callable(self, "_on_interact") #Assigning interact function
	tower = get_parent() as Tower2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		pass

func _on_interact(player: Player):
	if player.tower:
		if not player.is_controlling_tower:
			player.is_controlling_tower = true
			if player.piece_catied:
				var piece = player.piece_catied
				piece.release()
				piece.is_tetris_mode = true
				piece.get_parent().remove_child(piece)
				piece.tower = tower
				tower.add_child(piece)  # Add the instance to the tower node
				tower.ap_insert(piece)
		else: player.is_controlling_tower = false
		
		
func release():
	while true:
		if Input.is_action_just_pressed("interact"): #We wait for interaction again to release
			break
		await get_tree().process_frame #Otherwise we wait for next frame (pause)

func wait_for_no_input():
	while Input.is_action_pressed("interact"):
		await get_tree().process_frame


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		var player = body as Player
		player.tower = tower

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if is_instance_of(body, Player):
		var player = body as Player
		player.tower = null
		player.is_controlling_tower = false
