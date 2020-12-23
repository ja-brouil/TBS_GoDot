extends Node

class_name Movement_Arrow

# Queue for holding the cursor movement
var last_movements = []
var max_movement = 10
var previous_cell

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Queue Interaction -> Current cell is where the cursor is
func check_for_queue(current_cell: Cell):
	# Set Max Movement
	max_movement = BattlefieldInfo.current_Unit_Selected.UnitMovementStats.movementSteps
	
	# Clear current movement queue is not cleared
	BattlefieldInfo.current_Unit_Selected.UnitMovementStats.movement_queue.clear()
	
	# Do not add if not part of the current allowed tiles
	if BattlefieldInfo.current_Unit_Selected.UnitMovementStats.allowedMovement.has(current_cell):
		
		# Are we more than the allowed movement range?
		if last_movements.size() > max_movement:
			BattlefieldInfo.movement_calculator.get_path_to_destination(BattlefieldInfo.current_Unit_Selected, BattlefieldInfo.grid[BattlefieldInfo.cursor.position.x / Cell.CELL_SIZE][BattlefieldInfo.cursor.position.y / Cell.CELL_SIZE], BattlefieldInfo.grid)
			
			for c_cell in BattlefieldInfo.current_Unit_Selected.UnitMovementStats.movement_queue:
				add_to_queue(c_cell)
		else:
			current_cell.parentTile = previous_cell
			add_to_queue(current_cell)
			previous_cell = current_cell

func add_to_queue(both_cells):
	# Do not add cells that we already have
	both_cells.get_node("MovementRangeRect/Marked").visible = true
	last_movements.push_front(both_cells)

func clear_queue():
	for cell in BattlefieldInfo.current_Unit_Selected.UnitMovementStats.allowedMovement:
		cell.get_node("MovementRangeRect/Marked").visible = false
	
	last_movements.clear()
