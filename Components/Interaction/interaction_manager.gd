extends Node2D

#IMPORTANT: Project -> Project Settings -> Globals -> Add interaction_manager

@onready var player = get_tree().get_first_node_in_group("players") #Getting the players
@onready var label = $Label #Getting the label

const base_text = "[E] to " #Always present text start 
const distance_above = 36

var active_areas = [] #Will store all areas the player enters
var can_interact = true

func add_area(area: InteractionArea):
	active_areas.push_back(area)

func remove_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

func _process(delta):
	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player) #Finding nearest area
		label.text = base_text + active_areas[0].action_name #Displaying text over it 
		label.global_position = active_areas[0].global_position
		label.global_position.y -= distance_above
		label.global_position.x -= label.size.x / 2
		label.show()
	else:
		label.hide()
		
#Sorting function finding nearest interacble to player
func _sort_by_distance_to_player(area1, area2):
	var area1_distance = player.global_position.distance_to(area1.global_position)
	var area2_distance = player.global_position.distance_to(area2.global_position)
	return area1_distance < area2_distance

func _input(event):
	if event.is_action_pressed("interact") && can_interact: #Upon interaction 
		if active_areas.size() > 0: #If anything to interact with
			can_interact = false #Disallowing further interaction
			label.hide() #Hiding text
			
			await active_areas[0].interact.call() #Awaiting
			
			can_interact = true
