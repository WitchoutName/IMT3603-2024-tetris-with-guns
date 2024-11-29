extends Control

class_name EscapeMenu

#@onready var options_menu = $Options_Menu as OptionsMenu
@onready var vbox_container = $Panel/VBoxContainer as VBoxContainer

@export var player: Player

signal exit_to_lobby

func _ready():
	hide()
	if player:
		player.connect("toggle_player_paused", _on_player_toggle_player_paused )
	set_process_input(true)
	
	$Panel/VBoxContainer/OptionsButton.pressed.connect(_on_options_button_pressed)
	print("Options button pressed!")
	$Panel/VBoxContainer/Exit_to_Lobby_Button.pressed.connect(_on_exit_to_lobby_button_pressed)
	print("Exit button pressed!")

func _on_menu_opened():
	set_process_input(true)

func _on_menu_closed():
	set_process_input(false)
	 # Use shorthand if Menu is a child of the current node
	#var option_button = $Panel/VBoxContainer/Options  # Adjust to your node structure
	#var menu_node = $"."
	#if menu_node:
		# Connect the OptionButton's pressed signal to the menu's _on_options_button_pressed function
		#option_button.connect("pressed", Callable(menu_node, "_on_options_button_pressed"))
	#else:
		#print("Menu node not found!")


func _on_options_button_pressed():
	print("Options button pressed!")
	if OptionsManager:
		OptionsManager.open(self)
		OptionsManager.show()
		vbox_container.visible = false
		#options_menu.set_process(true)
		OptionsManager.visible = true
	
	else:
		print ("OptionsManager (autoload) is not available")
# Signal to notify the player script or main game script

func _on_exit_to_lobby_button_pressed():
	print("Exit to Lobby pressed!")
	emit_signal("exit_to_lobby")
	
	#Close the Optionsmenu if open
	if OptionsManager:
		OptionsManager.close()
		OptionsManager.hide()
	# Change the scene to the lobby
	get_tree().change_scene("res://Scenes/Menu/lobby/connection_lobby.tscn")


func _gui_input(event):
	if event.is_pressed():
		print("Escape menu received input!")


#func _on_exit_to_lobby_pressed() -> void:
	#pass # Replace with function body.
func _on_player_toggle_player_paused(is_paused: bool):
	if is_paused:
		show()
	else:
		hide()
	

func _on_resume_pressed() -> void:
	player.player_paused = false
