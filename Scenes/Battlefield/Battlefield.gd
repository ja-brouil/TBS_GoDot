extends Node
#########
#SYSTEMS#
#########

# Systems needed for the battlefield
var unit_movement_system
var movement_calculator
var turn_manager
var music_player

# Start battlefield game
func _ready():
	# Movement Calculator
	movement_calculator = MovementCalculator.new(self)
	
	# Movement System
	unit_movement_system = Unit_Movement_System.new()
	
	# Turn Manager
	turn_manager = Turn_Manager.new()
	add_child(turn_manager)
	
	# Music player
	music_player = preload("res://Scenes/Audio/MusicPlayer.tscn").instance()
	add_child(music_player)

# Run Systems
func _process(delta):
	unit_movement_system.process_movement(delta)

#######################
#BATTLEFIELD VARIABLES#
#######################

# Current Unit Selected
var current_Unit_Selected: Node2D

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

# Eirika for AI purposes
var Eirika

# Use a signal for this | Change this, just temporary
func next_ai(enemy_unit):
	enemy_unit.get_node("AI").process_ai()