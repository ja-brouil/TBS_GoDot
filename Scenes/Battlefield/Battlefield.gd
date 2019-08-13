extends Node2D

# Systems needed for the battlefield
var unit_movement_system
var movement_calculator

# Start battlefield game
func _ready():
	unit_movement_system = Unit_Movement_System.new(self)
	movement_calculator = MovementCalculator.new(self)

# Run Systems
func _process(delta):
	unit_movement_system.update(delta)

# Global variables needed for the entire battle field scene
var current_Unit_Selected: Node2D
var grid = []
var map_height
var map_width

func get_Current_Unit_Selected() -> Node2D:
	return current_Unit_Selected

func set_Current_Unit_Selected(Current_Unit_Selected: Node2D) -> void:
	self.current_Unit_Selected = Current_Unit_Selected