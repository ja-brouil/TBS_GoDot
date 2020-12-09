extends Node

# Queue for holding the cursor movement
var last_movements = []
var max_movement = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Queue Interaction
func add_to_queue(cell: Cell):
	last_movements.append(cell)
	
	if last_movements.size() < 10:
		pass # remove the last item in the array
