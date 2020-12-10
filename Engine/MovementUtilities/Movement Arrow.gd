extends Node

class_name Movement_Arrow

# Queue for holding the cursor movement
var last_movements = []
var max_movement = 10
var previous_cell

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Queue Interaction
func add_to_queue(current_cell: Cell):
	# Set Max Movement
	max_movement = BattlefieldInfo.current_Unit_Selected.UnitMovementStats.movementSteps
	
	var combo = [current_cell, previous_cell]
	previous_cell = current_cell
	
	# Do not add if not part of the current allowed tiles
	if BattlefieldInfo.movement_calculator.check_if_move_is_valid(combo[0], BattlefieldInfo.current_Unit_Selected):
		
		# Removes the last element if there are more 10 elements | This needs to be changed to create the movement queue
		if last_movements.size() > max_movement:
			BattlefieldInfo.movement_calculator.get_path_to_destination(BattlefieldInfo.current_Unit_Selected, current_cell, BattlefieldInfo.grid)
			
			# Clear the queue
			clear_queue()
			
			# Add them all
			for cell in BattlefieldInfo.current_Unit_Selected.UnitMovementStats.movement_queue:
				add_to_queue(cell)
		else:
			last_movements.push_front(combo)
			# Activate the color marker
			combo[0].get_node("MovementRangeRect/Marked").visible = true

func clear_queue():
	# Remove all items and remove all the markers
	for cell in last_movements:
		cell[0].get_node("MovementRangeRect/Marked").visible = false
	
	last_movements.clear()
