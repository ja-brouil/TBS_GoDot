# Represents all the units in the game
extends Node2D

class_name Battlefield_Unit

# Graphics
export(String) var sprite_dir = "Idle"
export(int) var animation_movement_speed = 5

# Movement -> Ally status is in here
var UnitMovementStats
var animation_movement

# Unit State
var UnitActionStatus

# Unit Stats
var UnitStats

# Inventory
var UnitInventory

# Unit portrait
var unit_portrait_path

# Unit Mugshot
var unit_mugshot

# Combat sprites
var combat_node

# Death sentence for allies
var death_sentence

func _ready():
	# Movement Stats
	UnitMovementStats = Unit_Movement.new()
	add_child(UnitMovementStats)

	# Unit Action state
	UnitActionStatus = Unit_Action_Status.new()
	add_child(UnitActionStatus)
	
	# Inventory
	UnitInventory = preload("res://Scenes/Units/Unit_Scripts/Inventory.tscn").instance()
	add_child(UnitInventory)
	
	# Unit stats
	UnitStats = Unit_Stats.new()
	add_child(UnitStats)

# Greyscale options
func turn_greyscale_on():
	self.modulate = Color(0.33, 0.34, 0.37, 1)

func turn_greyscale_off():
	self.modulate = Color(1, 1, 1, 1)

# Get Direction to face
# Returns the direction that the unit should be facing
func get_direction_to_face(starting_cell, destination_cell) -> String:
	# Right
	if starting_cell.getPosition().x - destination_cell.getPosition().x < 0 && starting_cell.getPosition().y - destination_cell.getPosition().y == 0:
		return "Right"
	# Left
	elif starting_cell.getPosition().x - destination_cell.getPosition().x > 0 && starting_cell.getPosition().y - destination_cell.getPosition().y == 0: 
		return "Left"
	# North
	elif starting_cell.getPosition().x - destination_cell.getPosition().x == 0 && starting_cell.getPosition().y - destination_cell.getPosition().y > 0:
		return "Up"
	# South
	elif starting_cell.getPosition().x - destination_cell.getPosition().x == 0 && starting_cell.getPosition().y - destination_cell.getPosition().y < 0:
		return "Down"
	# Fail safe
	else:
		return "Idle"