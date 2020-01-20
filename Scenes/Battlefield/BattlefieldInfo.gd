extends Node
#########
#SYSTEMS#
#########

# Systems needed for the battlefield
var unit_movement_system
var movement_calculator
var turn_manager
var combat_screen
var tile_unit_updater

# Cinematic Systems
var message_system
var main_game_camera
var turn_transition
var event_system
var movement_system_cinematic

# Level
var current_level # Level from TMX Files
var battlefield_container # Entire chapter
var level_container # Container for level

# Sound and music
var music_player
var battle_sounds
var weapon_sounds
var extra_sound_effects

# Victory Condition
var victory_text = "Defeat all enemies"

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

# Battlefield Unit Info
var ally_units = {}
var enemy_units = {}

# Spawn points
var spawn_points = []
var swap_points = []

# Eirika for AI purposes
var Eirika

# Enemy commander for status screen
var enemy_commander

# Combat Unit for combat screen
var combat_player_unit
var combat_ai_unit

# Player units
onready var y_sort_player_party

# Game Over
var game_over = false

# Victory
var victory = false

# Prevent end of turn
var stop_end_of_turn = false

# Money
var money = 0

##################
# ALL UI SCREENS #
##################

# Cursor
var cursor
var battlefield_ui

# End turn
var end_turn

# Weapon and healing select
var weapon_select
var healing_select

# Damage and healing preview
var damage_preview
var healing_preview

# Unit Info Screen
var unit_info_screen

# Prep screen
var preparation_screen

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
	tile_unit_updater = preload("res://Engine/Systems/TileUnitUpdater.tscn").instance()
	add_child(tile_unit_updater)
	
	# Victory Checker
	victory_system = preload("res://Engine/Systems/Victory Checker.tscn").instance()
	add_child(victory_system)
	
	# Player sort
	y_sort_player_party = $YSort

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
	combat_screen = null
	message_system = null
	current_level = null
	battlefield_container = null
	victory_text = ""
	cursor = null
	battlefield_ui = null
	current_Unit_Selected = null
	combat_ai_unit = null
	combat_player_unit = null
	grid = null
	map_height = 0
	map_width = 0
	enemy_units = null
	game_over = false
	victory = false
	enemy_commander = null
	turn_transition = null
	unit_info_screen = null
	event_system = null
	stop_end_of_turn = false

	# Reset turn manager
	turn_manager.player_turn_number = 1
	turn_manager.enemy_turn_number = 1

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