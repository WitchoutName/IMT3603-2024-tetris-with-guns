extends Node

class_name GameManagerClass

enum GameState {
	CONNECTION_LOBBY,
	PLAYING,
	WIN
}

var game_state = GameState.CONNECTION_LOBBY
var lobby: ConnectionLobby
var _players: Dictionary = {}

var players: Array:
	get: return _players.values()

var team1: Array:
	get: return players.filter(func(p: PlayerPeer): return p.team == 1)
var team2: Array:
	get: return players.filter(func(p: PlayerPeer): return p.team == 2)



func add_player(id: int, name: String):
	if !_players.has(id):
		var player = PlayerPeer.new()
		player.id = id
		player.username = name
		player.team = 1
		_players[id] = player

func remove_player(id: int):
	if _players.has(id):
		var player: PlayerPeer = _players[id]
		if player.entity:
			player.entity.queue_free()
		_players.erase(id)

func player_change_team(player_id: int, team: int):
	if _players[player_id]:
		_players[player_id].team = team
	else:
		push_error("Failed switching teams. Player id {}" % player_id + "not found")

@rpc("authority")
func _sync_state(players):
	print(multiplayer.multiplayer_peer.get_unique_id(), " sync mg:")
	_players = players

func sync_state():
	_sync_state.rpc(_players)


func start_game():
	var scene = load("res://Scenes/world.tscn").instantiate()
	get_tree().root.add_child(scene)
	lobby.hide()
