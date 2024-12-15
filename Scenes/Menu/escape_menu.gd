extends Control

class_name EscapeMenu

#@onready var options_menu = $Options_Menu as OptionsMenu
@onready var vbox_container = $Display/Panel/VBoxContainer as VBoxContainer
@onready var options_menu: OptionsMenu = $Display/Options_Menu
@onready var display: CanvasLayer = $Display

@onready var health: Health = $Health

@onready var player: Player

signal exit_to_lobby

func _ready():
	close()
	#if player:
		#player.connect("toggle_player_paused", _on_player_toggle_player_paused)
	#set_process_input(true)
	if options_menu:
		options_menu.exit_options_menu.connect(on_exit_options_menu)
	else:
		print("OptionsManager is not available!")
	
	
func open():
	display.show()
	show()
	
func close():
	display.hide()
	hide()


func _on_menu_opened():
	set_process_input(true)

func _on_menu_closed():
	set_process_input(false)
	


func _on_options_button_pressed():
	print("Options button pressed!")
	if options_menu:
		vbox_container.hide()
		options_menu.open()
		set_process_input(false)
		options_menu.set_process_input(true)
		
		print("OptionsManager opned from EscapeMenu")
	
	else:
		print ("OptionsManager (autoload) is not available")
# Signal to notify the player script or main game script
func on_exit_options_menu() -> void:	
	show()
	vbox_container.show()
	set_process_input(true)
	if options_menu:
		options_menu.close()
		print("OptionsMenu closed from EscapeMenu")
	else:
		print("OptionsManager is not available")
		

func _on_exit_to_lobby_button_pressed():
	print("Exit to Lobby pressed!")
	hide()
	emit_signal("exit_to_lobby")
	
	#Close the Optionsmenu if open
	if options_menu:
		options_menu.close()
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


func _on_respawn_button_pressed():
	#print("Respawn button pressed")
	hide()
	if player:
		player.health.take_damage(999)
		#print("Should be dead")
	if options_menu:
		options_menu.close()
	#print("Done with loop")
	display.hide()
	player.player_paused = false
	


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
	close()
	player.player_paused = false
