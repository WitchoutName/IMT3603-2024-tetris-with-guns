extends Control

class_name ConnectionLobby

@export var ip_ddress = "127.0.0.1"
@export var port = 45454
var peer: ENetMultiplayerPeer
var lobby_log_lines = []

var username: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.game_state = GameManager.GameState.CONNECTION_LOBBY
	GameManager.lobby = self
	multiplayer.allow_object_decoding = true
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	lobby_log("Host or join a lobby!")
	if "--server" in OS.get_cmdline_args():
		host_game()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func lobby_log(message: String):
	lobby_log_lines.insert(0, message)
	print(multiplayer.multiplayer_peer.get_unique_id(), message)
	$LogDisplay.text = "\n".join(lobby_log_lines)
	
func update_team_labels():
	$TeamsGroup/Team1Text.text = "Team 1:\n" + "\n".join(GameManager.team1.map(func(p): return p.username))
	$TeamsGroup/Team2Text.text = "Team 2:\n" + "\n".join(GameManager.team2.map(func(p): return p.username))

# this get called on the server and clients
func peer_connected(id):
	lobby_log("[Net]Peer " + str(id) + " Connected")
	
# this get called on the server and clients
func peer_disconnected(id):
	lobby_log("[Net]Peer " + str(id) + " Disconnected")
	if multiplayer.is_server():
		GameManager.remove_player(id)
		GameManager.sync_state()
	update_team_labels()
	
			
# called only from clients
func connected_to_server():
	print(multiplayer.multiplayer_peer.get_unique_id(), "connected To Sever!")
	register_player.rpc_id(1, multiplayer.get_unique_id(), username)

# called only from clients
func connection_failed():
	print(multiplayer.multiplayer_peer.get_unique_id(), "Couldnt Connect")

@rpc("any_peer")
func register_player(id: int, name: String):
	GameManager.add_player(id, name)
	update_team_labels()
	lobby_log("Player '" + name + "' joined Team 1")
	GameManager.sync_state.rpc(GameManager._players)
	

@rpc("any_peer", "call_local")
func player_change_team(player_id: int, team: int):
	GameManager.player_change_team(player_id, team)
	update_team_labels()
	lobby_log("Player '" + GameManager._players[player_id].username + "' changed to team to Team " + str(team))
	GameManager.sync_state.rpc()
	


@rpc("authority","call_local")
func start_game():
	GameManager.start_game()

	
func host_game():
	peer = ENetMultiplayerPeer.new()
	port = int($JoinGroup/TextPort.text)
	var error = peer.create_server(port, 2)
	if error != OK:
		print("cannot host: ", error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	$StartGroup.visible = true
	
	multiplayer.set_multiplayer_peer(peer)
	lobby_log("Waiting For Players!")
	
	
func process_username() -> bool:
	username = $NameGroup/TextEdit3.text
	if username == "":
		lobby_log("Can't have an empty username!")
		return false
	return true



func leave():
	lobby_log_lines = []
	lobby_log("Host or join a lobby!")
	$JoinGroup/JoinButton.disabled = false
	$HostButton.disabled = false
	$StartGroup.visible = false
	$TeamsGroup.visible = false
	peer.close()


@rpc("authority", "call_local")
func lobby_host_left():
	leave()
	
	
func _on_host_button_button_down() -> void:
	if process_username():
		lobby_log_lines = []
		$JoinGroup/JoinButton.disabled = true
		$HostButton.disabled = true
		$TeamsGroup.visible = true
		host_game()
		register_player(multiplayer.get_unique_id(), username)


func _on_join_button_button_down() -> void:
	if process_username():
		peer = ENetMultiplayerPeer.new()
		ip_ddress = $JoinGroup/TextIP.text
		port = int($JoinGroup/TextPort.text)
		var error = peer.create_client(ip_ddress, port)
		if error != OK: return lobby_log("Could not connect")
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		print(peer.get_unique_id())
		multiplayer.set_multiplayer_peer(peer)	
		lobby_log_lines = []
		$JoinGroup/JoinButton.disabled = true
		$HostButton.disabled = true
		$TeamsGroup.visible = true
		$TeamsGroup/JoinTeam1Button.disabled = true
		$TeamsGroup/JoinTeam2Button.disabled = false


func _on_leave_button_button_down() -> void:
	if peer.get_unique_id() == 1:
		lobby_host_left.rpc()
	else:
		leave()

func _on_start_game_button_button_down() -> void:
		start_game.rpc()



func _on_join_team_1_button_button_down() -> void:
	$TeamsGroup/JoinTeam1Button.disabled = true
	$TeamsGroup/JoinTeam2Button.disabled = false
	player_change_team.rpc_id(1, peer.get_unique_id(), 1)


func _on_join_team_2_button_button_down() -> void:
	$TeamsGroup/JoinTeam1Button.disabled = false
	$TeamsGroup/JoinTeam2Button.disabled = true
	player_change_team.rpc_id(1, peer.get_unique_id(), 2)
