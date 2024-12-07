extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@export var player_camera_shift = -500
var tower: Tower2 

# Called when the node enters the scene tree for the first time.
func _ready():
	interaction_area.interact = _on_interact #Assigning interact function
	tower = get_parent() as Tower2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		pass

func _on_interact(player: Player):
	if not player == GameManager.my_player: return
	print(multiplayer.is_server(), " ", player.player_peer.id)
	if player.tower:
		if not player.is_controlling_tower:
			player.is_controlling_tower = true
			if player.Camera: player.Camera.position.y = player_camera_shift
			if player.piece_catied:
				var piece = player.piece_catied
				insert.rpc(piece.get_path())
				tower.ap_insert.rpc_id(1, piece.get_path())
				piece.set_multiplayer_authority(1)

		else: 
			player.is_controlling_tower = false
			if player.Camera: player.Camera.position.y = 0


@rpc("any_peer", 'call_local')
func insert(piece_path):
	var piece = get_node(piece_path)
	piece.release()
	piece.is_tetris_mode = true
	piece.get_parent().remove_child(piece)
	piece.tower = tower
	tower.add_child(piece)  # Add the instance to the tower node


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		var player = body as Player
		if not player == GameManager.my_player: return
		print(multiplayer.is_server(), " setting tower of player ", player.name)
		player.tower = tower

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if is_instance_of(body, Player):
		var player = body as Player
		if not player == GameManager.my_player: return
		player.tower = null
		player.is_controlling_tower = false
		if player.Camera: player.Camera.position.y = 0;
