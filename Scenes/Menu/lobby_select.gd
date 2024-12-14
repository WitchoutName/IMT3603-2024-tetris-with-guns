extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_input(false) # Replace with function body.

func _on_menu_opened():
	set_process_input(true)

func _on_menu_closed():
	set_process_input(false)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu/main.tscn")



func _on_enter_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/world.tscn")
