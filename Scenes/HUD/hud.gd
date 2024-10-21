# This script will create a HUD in Godot for a 2D fighter game similar to the provided image.
# We assume that you have already set up the scene with the required control nodes.

extends Node2D

# Declare variables for the UI elements
var team_score_blue
var team_score_red
var timer_label
var health_bar
var shield_bar
var weapon_icon1
var weapon_icon2
var ammo_label

func _ready():
	# Get references to UI elements
	team_score_blue = $Display/TopPanel/TeamScoreBlue
	team_score_red = $Display/TopPanel/TeamScoreRed
	timer_label = $Display/TopPanel/Timer
	health_bar = $Display/BottomLeft/HealthBar
	shield_bar = $Display/BottomLeft/ShieldBar
	weapon_icon1 = $Display/BottomRight/WeaponIcon1
	weapon_icon2 = $Display/BottomRight/WeaponIcon2
	ammo_label = $Display/BottomRight/Ammo

	# Set dummy values for testing
	set_dummy_values()

# Function to update team scores
func update_team_scores(blue_score: int, red_score: int):
	if team_score_blue != null:
		team_score_blue.value = blue_score
		if team_score_blue.get_child_count() > 0 and team_score_blue.get_child(0) is Label:
			var blue_label_node = team_score_blue.get_child(0)
			blue_label_node.text = str(blue_score)
	if team_score_red != null:
		team_score_red.value = red_score
		if team_score_red.get_child_count() > 0 and team_score_red.get_child(0) is Label:
			var red_label_node = team_score_red.get_child(0)
			red_label_node.text = str(red_score)

# Function to update the timer
func update_timer(time_left: int):
	var minutes = time_left / 60
	var seconds = time_left % 60
	if timer_label != null:
		timer_label.text = "%02d:%02d" % [minutes, seconds]

# Function to update health
func update_health(health: int):
	if health_bar != null:
		health_bar.value = health
		if health_bar.get_child_count() > 0 and health_bar.get_child(0) is Label:
			var health_label_node = health_bar.get_child(0)
			health_label_node.text = str(health) + " / 100"

# Function to update shield
func update_shield(shield: int):
	if shield_bar != null:
		shield_bar.value = shield
		if shield_bar.get_child_count() > 0 and shield_bar.get_child(0) is Label:
			var shield_label_node = shield_bar.get_child(0)
			shield_label_node.text = str(shield)

# Function to update ammo
func update_ammo(current_ammo: int, max_ammo: int):
	if ammo_label != null:
		ammo_label.text = str(current_ammo) + " / " + str(max_ammo)

# Function to highlight the currently selected weapon
func highlight_weapon(weapon_number: int):
	if weapon_icon1 != null and weapon_icon2 != null:
		if weapon_number == 1:
			weapon_icon1.modulate = Color(1, 1, 1, 1)  # Highlight (white)
			weapon_icon2.modulate = Color(0.5, 0.5, 0.5, 1)  # Dim (gray)
		elif weapon_number == 2:
			weapon_icon1.modulate = Color(0.5, 0.5, 0.5, 1)  # Dim (gray)
			weapon_icon2.modulate = Color(1, 1, 1, 1)  # Highlight (white)

# Function to handle updates based on game state (e.g. health decrease, ammo usage)
func _process(delta):
	pass  # This will be filled in with actual game logic later

# Function to set dummy values for testing
func set_dummy_values():
	update_team_scores(8, 6)
	update_timer(300)
	update_health(87)
	update_shield(44)
	update_ammo(17, 30)
	highlight_weapon(1)
