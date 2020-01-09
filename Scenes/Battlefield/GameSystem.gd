extends Node
#########
#SYSTEMS#
#########

# Systems needed for the battlefield
var unit_movement_system
var movement_calculator
var turn_manager
var combat_screen

# Cinematic Systems
var message_system
var main_game_camera
var turn_transition
var event_system
var movement_system_cinematic

# Level
var current_level
var battlefield_container

# Sound and music
var music_player
var battle_sounds
var weapon_sounds
var extra_sound_effects

# Cursor
var cursor
var battlefield_ui

# Unit Info Screen
var unit_info_screen

# Victory Condition
var victory_text

# Victory System
var victory_system

###########################
#GLOBAL GAMEPLAY VARIABLES#
###########################
# Current Unit Selected
var current_Unit_Selected: Node2D

# Previous position in order to be able to go back
var previous_position = Vector2(0,0)

# Previous camera position
var previous_camera_position = Vector2(0,0)

# Map Info
var grid = []
var map_height
var map_width

# Camera Values
var camera_limit_bottom
var camera_limit_right

# Battlefield Unit Info
var ally_units = {}
var enemy_units = {}
var ally_units_y_sort_node

# Spawn points
var spawn_points = []

# Eirika for AI purposes
var Eirika

# Enemy commander for status screen
var enemy_commander

# Combat Unit for combat screen
var combat_player_unit
var combat_ai_unit

# Game Over
var game_over = false

# Victory
var victory = false

# Money
var money = 0

# Start Game Systems
func _ready():
	# Movement Calculator
	movement_calculator = MovementCalculator.new(self)
	
	# Movement System
	unit_movement_system = preload("res://Engine/Systems/Unit_Movement_System.gd").new()
	unit_movement_system.set_name("Unit Movement System")
	add_child(unit_movement_system)
	
	# Cinematic Movement System
	movement_system_cinematic = preload("res://Engine/Systems/Unit_Movement_System_Cinematic.gd").new()
	movement_system_cinematic.set_name("Movement System Cinematic")
	add_child(movement_system_cinematic)
	
	# Turn Manager
	turn_manager = preload("res://Engine/Systems/Turn Manager.tscn").instance()
	add_child(turn_manager)
	
	# Music player
	music_player = preload("res://Scenes/Audio/MusicPlayer.tscn").instance()
	add_child(music_player)
	
	# Battle Sounds
	battle_sounds = preload("res://Scenes/Audio/Battle Sounds.tscn").instance()
	add_child(battle_sounds)
	
	# Weapon Sounds
	weapon_sounds = preload("res://Scenes/Audio/Weapon Sounds.tscn").instance()
	add_child(weapon_sounds)
	
	# Extra sounds
	extra_sound_effects = preload("res://Scenes/Audio/Extra Sound Effects.tscn").instance()
	add_child(extra_sound_effects)
	
	# Map Updater
	
	# Victory Checker
	victory_system = preload("res://Engine/Systems/Victory Checker.tscn").instance()
	add_child(victory_system)
	

# Run Systems
func _process(delta):
	unit_movement_system.process_movement(delta)
	movement_system_cinematic.process_movement(delta)

# Global Hotkeys
func _input(event):
	if Input.is_action_just_pressed("exit_game"):
		get_tree().quit()

# Clear for starting
func clear():
	current_level = null
	victory_text = null
	cursor = null
	battlefield_ui = null
	current_Unit_Selected = null
	combat_ai_unit = null
	combat_player_unit = null
	grid = null
	map_height = null
	map_width = null
	ally_units = null
	enemy_units = null

# Start the level
func start_level():
	turn_transition.start_level()

# AI Functions
func next_ai(enemy_unit):
	enemy_unit.get_node("AI").process_ai()
	
func start_ai_combat():
	# Calculate damage
	Combat_Calculator.calculate_damage()
	
	# Start Combat screen
	combat_screen.start_combat(Combat_Screen.enemy_first_turn)
