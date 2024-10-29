extends BaseMap


func _ready() -> void:
	var team1 = Team.new()
	team1.spawn_point = $leftTeam/spawnPoint
	team1.tower = $leftTeam/Tower
	teams.append(team1)
	
	var team2 = Team.new()
	team2.spawn_point = $rightTeam/spawnPoint
	team2.tower = $rightTeam/Tower
	teams.append(team2)
	
	bullet_group = $BulletGroup
