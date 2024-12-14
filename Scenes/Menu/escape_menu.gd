extends Control

class_name EscapeMenu

#@onready var options_menu = $Options_Menu as OptionsMenu
@onready var vbox_container = $Panel/VBoxContainer as VBoxContainer

@export var player: Player

signal exit_to_lobby

func _ready():
	hide()
	if player:
		player.connect("toggle_player_paused", _on_player_toggle_player_paused)
	set_process_input(true)
	if OptionsManager:
		OptionsManager.exit_options_menu.connect(on_exit_options_menu)
	else:
		print("OptionsManager is not available!")
	
	

func _on_menu_opened():
	set_process_input(true)

func _on_menu_closed():
	set_process_input(false)
	


func _on_options_button_pressed():
	print("Options button pressed!")
	if OptionsManager:
		OptionsManager.open(self)
		OptionsManager.show()
		vbox_container.visible = false
		set_process_input(false)
		OptionsManager.set_process_input(true)
		OptionsManager.visible = true
		
		print("OptionsManager opned from EscapeMenu")
	
	else:
		print ("OptionsManager (autoload) is not available")
# Signal to notify the player script or main game script
func on_exit_options_menu() -> void:	
	vbox_container.visible = true
	set_process_input(true)
	if OptionsManager:
		OptionsManager.close()
		OptionsManager.visible = false
		print("OptionsMenu closed from EscapeMenu")
	else:
		print("OptionsManager is not available")
		

func _on_exit_to_lobby_button_pressed():
	print("Exit to Lobby pressed!")
	hide()
	emit_signal("exit_to_lobby")
	
	#Close the Optionsmenu if open
	if OptionsManager:
		OptionsManager.close()
		OptionsManager.hide()
	if player:
		player.player_paused = true
		
	# Change the scene to the lobby
	get_tree().change_scene_to_file("res://Scenes/Menu/lobby/connection_lobby.tscn")
	
	#Use yield to ensure scene change is complete
	#await get_tree().process_frame
	
	#Ensure the game is not paused
	#get_tree().paused = false
	
	# Ensure input is processing
	set_process_input(false)


func _gui_input(event):
	if event.is_pressed():
		print("Escape menu received input!")


#func _on_exit_to_lobby_pressed() -> void:
	#pass # Replace with function body.
func _on_player_toggle_player_paused(is_paused: bool):
	if(is_paused):
		show()
	else:
		hide()
	

func _on_resume_pressed() -> void:
	get_tree().paused = false
	player.player_paused = false
	print(player.player_paused)
