extends Node

class_name GameManagerClass

enum GameState {
	CONNECTION_LOBBY,
	PLAYING,
	WIN
}

var game_state = GameState.CONNECTION_LOBBY
var lobby: ConnectionLobby
var map: BaseMap
var my_id: int
var _players: Dictionary = {}

var players: Array:
	get: return _players.values()

var team1: Array:
	get: return players.filter(func(p: PlayerPeer): return p.team == 1)
var team2: Array:
	get: return players.filter(func(p: PlayerPeer): return p.team == 2)
	
var my_player: Player:
	get: return _players[my_id].entity


@rpc("authority", "call_local", "reliable")
func add_player(id: int, name: String):
	print(multiplayer.get_unique_id(), "add_player")
	if !_players.has(id):
		var player = PlayerPeer.new()
		player.id = id
		player.username = name
		player.team = 1
		_players[id] = player
	if not multiplayer.is_server():
		print("non host app_player", players)

@rpc("authority", "call_local", "reliable")
func remove_player(id: int):
	print(multiplayer.get_unique_id(), "remove_player")
	if _players.has(id):
		var player: PlayerPeer = _players[id]
		if player.entity:
			player.entity.queue_free()
		_players.erase(id)
	if not multiplayer.is_server():
		print("non host remove_player", players)

@rpc("authority", "call_local", "reliable")
func player_change_team(player_id: int, team: int):
	if _players[player_id]:
		_players[player_id].team = team
	else:
		push_error("Failed switching teams. Player id {}" % player_id + "not found")

func sync_players():
	print(players.map(func(p): return p.id), players.map(func(p): return p.username))
	_sync_players.rpc(players.map(func(p): return p.id), players.map(func(p): return p.username))
	_sync_players_fake.rpc()

@rpc("authority", "call_remote", "reliable")
func _sync_players(ids, names):
	print(multiplayer.get_unique_id(), "_sync_players")
	for id in _players.keys().filter(func(k): return k not in ids):
		remove_player(id)
	for id in ids.filter(func(k): return k not in _players.keys()):
		var i = ids.find(id)
		add_player(id, names[i])
	
@rpc("authority", "call_remote", "reliable")
func _sync_players_fake():
	print(multiplayer.get_unique_id(), "_sync_players_fake")
	#for id in _players.keys().filter(func(k): return k not in ids):
		#remove_player(id)
	#for id in ids.filter(func(k): return k not in _players.keys()):
		#var i = ids.find(id)
		#add_player(id, names[i])

@rpc("authority", "call_local", "reliable")
func start_game():
	game_state = GameState.PLAYING
	map = load("res://Scenes/Maps/world.tscn").instantiate()
	get_tree().root.add_child(map)
	lobby.hide()
	map.init()