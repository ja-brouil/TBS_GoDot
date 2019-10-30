extends Node2D
class_name BattlefieldInfo

#########
#SYSTEMS#
#########

# Systems needed for the battlefield
var unit_movement_system
var movement_calculator
var turn_manager

# Start battlefield game
func _ready():
	movement_calculator = MovementCalculator.new(self)

# Run Systems
func _process(delta):
	pass

#######################
#BATTLEFIELD VARIABLES#
#######################

# Current Unit Selected
var current_Unit_Selected: Node2D

# Map Info
var grid = []
var map_height
var map_width

# Battlefield Unit Info
var ally_units = {}
var enemy_units = {}

#########
#GET/SET#
#########
func get_Current_Unit_Selected() -> Node2D:
	return current_Unit_Selected

func set_Current_Unit_Selected(Current_Unit_Selected: Node2D) -> void:
	self.current_Unit_Selected = Current_Unit_Selected