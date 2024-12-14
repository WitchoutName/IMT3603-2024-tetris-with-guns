extends Control

@onready var options_menu = $Options_Menu as OptionsMenu
@onready var vbox_container = $VBoxContainer as VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$VBoxContainer/StartButton.grab_focus()
	handle_connecting_signals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/lobby/connection_lobby.tscn")


func _on_options_button_pressed() -> void:
	vbox_container.visible = false
	options_menu.set_process(true)
	options_menu.open()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
func on_exit_options_menu() -> void:	
	vbox_container.visible = true
	options_menu.visible = false
	
	
func handle_connecting_signals() -> void:
		options_menu.exit_options_menu.connect(on_exit_options_menu)
