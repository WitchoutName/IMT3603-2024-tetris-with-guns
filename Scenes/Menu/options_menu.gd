class_name OptionsMenu
extends Control

#@onready var back_button = $MarginContainer/VBoxContainer/Back as Button
#@export var option_menu_scene = preload("res://Scenes/Menu/options_menu.tscn")
var instance: Control = null  # Tracks the active instance of the Option Menu
@onready var display: CanvasLayer = $Display

signal exit_options_menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display.hide()
	return
	if not has_node("MarginContainer/VBoxContainer/Back"):
		print("Back button node not found in the current tree.")
		return
	
	# If the node exists, connect its signal
	var back_button = $MarginContainer/VBoxContainer/Back as Button
	back_button.pressed.connect(on_back_pressed)
	#set_process(false)
	
func _process(delta):
	if visible:
		pass
		#print("OptionsMenu is visible and active")
	
func on_back_pressed() -> void:
	exit_options_menu.emit()
	#set_process(false)
	close()
	
func open():
	display.show()
	show()
	return
	if instance:  # Prevent multiple instances
		print("Option Instance is Valid!")
		return
	# Instantiate the Option Menu scene and add it as a child
	#instance = option_menu_scene.instantiate()
	#parent_node.add_child(self) if !get_parent() else null
	self.show()
	set_process_input(true)
	#parent_node.add_child(instance)
	print("Options Menu opened!")

func close():
	display.hide()
	hide()
	return
	if is_instance_valid(self.get_parent()):
		get_parent().remove_child(self)
		#instance.queue_free()
		#instance = null
		print("Options Menu closed!")


func _on_back_pressed() -> void:
	exit_options_menu.emit()
	set_process(false)
	close()
