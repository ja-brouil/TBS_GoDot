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
func check_for_queue(current_cell: Cell):
	# Set Max Movement
	max_movement = BattlefieldInfo.current_Unit_Selected.UnitMovementStats.movementSteps
	
	var combo = []
	previous_cell = current_cell
	combo.push_back(current_cell)
	combo.push_back(previous_cell)
	
	# Do not add if not part of the current allowed tiles
	if BattlefieldInfo.current_Unit_Selected.UnitMovementStats.allowedMovement.has(combo[0]):
		# Removes the last element if there are more 10 elements | This needs to be changed to create the movement queue
		if last_movements.size() > max_movement:
			BattlefieldInfo.movement_calculator.get_path_to_destination(BattlefieldInfo.current_Unit_Selected, BattlefieldInfo.grid[BattlefieldInfo.cursor.position.x / Cell.CELL_SIZE][BattlefieldInfo.cursor.position.y / Cell.CELL_SIZE], BattlefieldInfo.grid)
			
			# Clear the queue
			clear_queue()
			
			previous_cell = BattlefieldInfo.current_Unit_Selected.UnitMovementStats.movement_queue.front()
			
			# Add them all
			for cell in BattlefieldInfo.current_Unit_Selected.UnitMovementStats.movement_queue:
				var new_combo = [current_cell, previous_cell]
				add_to_queue(new_combo)
				previous_cell = cell
				
		else:
			add_to_queue(combo)

func add_to_queue(both_cells):
	both_cells[0].get_node("MovementRangeRect/Marked").visible = true
	last_movements.push_front(both_cells)

func clear_queue():
	# Remove all items and remove all the markers
	for cell in last_movements:
		cell[0].get_node("MovementRangeRect/Marked").visible = false
	
	last_movements.clear()
