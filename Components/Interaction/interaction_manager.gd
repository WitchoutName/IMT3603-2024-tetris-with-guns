extends Node2D

#IMPORTANT: Project -> Project Settings -> Globals -> Add interaction_manager

@onready var player: Player = get_tree().get_first_node_in_group("players") #Getting the players
@onready var label = $Label #Getting the label

const base_text = "[E] to " #Always present text start 
const distance_above = 36

var active_areas_dict = {} #Will store all areas the player enters
var active_areas: Array[InteractionArea]:
	get = _get__active_areas
var can_interact_dict = {}

func _get__active_areas():
	var res = []
	active_areas_dict.values().all(func(a): res += a)
	return res

func add_area(area: InteractionArea):
	var array = active_areas_dict.get_or_add(area.interaction_group, [])
	array.push_back(area)
	var can_interact = can_interact_dict.get_or_add(area.interaction_group, true)

func remove_area(area: InteractionArea):
	var array = active_areas_dict.get_or_add(area.interaction_group)
	var index = array.find(area)
	if index != -1:
		array.remove_at(index)

func _process(delta):
	var label_shown = false
	var keys = active_areas_dict.keys()
	keys.reverse()
	for interactive_group in keys:
		if not label_shown:
			var area_list = active_areas_dict[interactive_group]
			if area_list.size() > 0 && can_interact_dict[interactive_group]:
				area_list.sort_custom(_sort_by_distance_to_player) #Finding nearest area
				label.text = base_text + area_list[0].action_name #Displaying text over it 
				label.global_position = area_list[0].global_position
				label.global_position.y -= distance_above
				label.global_position.x -= label.size.x / 2
				label.show()
				label_shown = true
			else:
				label.hide()
	if not label_shown:
		label.hide()
		
#Sorting function finding nearest interacble to player
func _sort_by_distance_to_player(area1: InteractionArea, area2: InteractionArea):
	#if area1.interactive_group != area2.interactive_group:
		#return area1.interactive_group > area2.interactive_group
	var area1_distance = player.global_position.distance_to(area1.global_position)
	var area2_distance = player.global_position.distance_to(area2.global_position)
	return area1_distance < area2_distance

func _input(event):
	if event.is_action_pressed("interact") && can_interact_dict.values().any(func(x): return x): #Upon interaction 
		var keys = can_interact_dict.keys()
		keys.reverse()
		for interactive_group in keys:
			var array = active_areas_dict[interactive_group]
			if array.size() > 0: #If anything to interact with
				can_interact_dict[interactive_group] = false #Disallowing further interaction
				label.hide() #Hiding text
				
				await array[0].interact.call(player) #Awaiting
				
				can_interact_dict[interactive_group] = true
				return
