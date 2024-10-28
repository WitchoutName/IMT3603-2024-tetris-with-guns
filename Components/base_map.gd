extends Node2D
class_name BaseMap

var teams: Array[Team]
var bullet_group: Node2D


var SPAWN_POINT = load("res://Entities/Player/SpawnPoint/spawn_point.tscn")
var PLAYER = load("res://Entities/Player/player.tscn")

func init() -> void:
	var player_peers = GameManager.players
	var team_count = 0
	for player_peer in player_peers:
		if player_peer.team > team_count:
			team_count = player_peer.team
			
	if team_count > len(teams): push_error("Too many teams of peers")

	for player_peer in player_peers:
		var spawn_point: PlayerSpawnPoint = SPAWN_POINT.instantiate()
		var player: Player = PLAYER.instantiate()
		var team: Team = teams[player_peer.team-1]
		player.name = str(player_peer.id)
		player.player_peer = player_peer
		player_peer.entity = player
		$PlayersGroup.add_child(player)
		player.global_position = team.spawn_point.global_position
		team.spawn_point.add_child(spawn_point)
		spawn_point.assign_player(player)

		player.collision_layer = int(pow(2, 20+player_peer.team-1))
		player.collision_mask = 1
		for i in range(len(teams)):
			if player_peer.team-1 == i: continue
			player.collision_mask = player.collision_mask | int(pow(2, 20+i))
			
		if player_peer.id == multiplayer.get_unique_id():
			InteractionManager.player = player
		else:
			player.Camera.queue_free()
		
		#player.synchroniser.set_multiplayer_authority(player_peer.id)

		


func _ready() -> void:
	pass

func reset():
	for team in teams:
		team.tower.reset()
		
	get_tree().call_group("PlayerSpawners", "reset")