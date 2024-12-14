extends Node2D
class_name BaseMap

var teams: Array[Team]
@export var team_colors: Array[Color] = [Color.MEDIUM_BLUE, Color.RED, Color.YELLOW, Color.WEB_GREEN]
@onready var bullet_group: Node2D = $BulletsGroup
@onready var player_group: Node2D = $PlayersGroup
@onready var item_group: Node2D = $ItemsGroup
@onready var tetramino_group: Node2D = $TetraminoGroup
@onready var HUD: Node2D = $HUD
signal map_setup_finished

var SPAWN_POINT = preload("res://Entities/Player/SpawnPoint/spawn_point.tscn")
var PLAYER = preload("res://Entities/Player/player.tscn")


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
		player_group.add_child(player)
		player.global_position = team.spawn_point.global_position
		team.spawn_point.add_child(spawn_point)
		spawn_point.assign_player(player)
		player.health_bar.modulate = team_colors[player_peer.team-1]

		player.collision_layer = int(pow(2, 20+player_peer.team-1))
		player.collision_mask = 1
		for i in range(len(teams)):
			if player_peer.team-1 == i: continue
			player.collision_mask = player.collision_mask | int(pow(2, 20+i))
			
		if player_peer.id == multiplayer.get_unique_id():
			InteractionManager.player = player
			GameManager.escape_menu.player = player
		else:
			player.Camera.queue_free()
			player.AudioListener.queue_free()
		
		#player.synchroniser.set_multiplayer_authority(player_peer.id)
	map_setup_finished.emit()


func _ready() -> void:
	print("[map] READY")

func reset():
	for team in teams:
		team.tower.reset()
		
	get_tree().call_group("PlayerSpawners", "reset")

func write_round_end_text(team: Team):
	var canvas = CanvasLayer.new()
	self.add_child(canvas)
	
	var label = Label.new()
	if(teams[GameManager.get_my_team_index()] == team):
		label.text = "Victory!"
	else:
		label.text = "Game Over!"

	label.add_theme_color_override("font_color", Color(1, 0, 0))
	
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	label.global_position += Vector2(0, -100)
	canvas.add_child(label)
	
	await get_tree().create_timer(5).timeout
