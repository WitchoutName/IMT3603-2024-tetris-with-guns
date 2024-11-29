class_name OptionsMenu
extends Control

@onready var back_button = $MarginContainer/VBoxContainer/Back as Button
#@export var option_menu_scene = preload("res://Scenes/Menu/options_menu.tscn")
var instance: Control = null  # Tracks the active instance of the Option Menu

signal exit_options_menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	if not has_node("MarginContainer/VBoxContainer/Back"):
		print("Back button node not found in the current tree.")
		return
	
	# If the node exists, connect its signal
	var back_button = $MarginContainer/VBoxContainer/Back as Button
	back_button.pressed.connect(on_back_pressed)
	set_process(false)
	
func on_back_pressed() -> void:
	exit_options_menu.emit()
	set_process(false)
	
func open(parent_node: Node):
	if instance:  # Prevent multiple instances
		print("Options Menu is already open!")
		return
	# Instantiate the Option Menu scene and add it as a child
	#instance = option_menu_scene.instantiate()
	OptionsManager.show()
	parent_node.add_child(instance)
	print("Options Menu opened!")

func close():
	if instance:
		instance.queue_free()
		instance = null
		print("Options Menu closed!")
