# Controls the movement system for the units
class_name Unit_Movement_System

# On/off
var is_moving
var battlefield

# Signal for camera update
signal unit_moved

# Update the world info
signal unit_finished_moving

func _init(battlefield):
	is_moving = false
	self.battlefield = battlefield

func update(delta):
	if !is_moving:
		return
	
	# Variables needed to move the units
	var unit = battlefield.get_Current_Unit_Selected()
	var starting_cell = unit.UnitMovementStats.currentTile
	var destination_cell = unit.UnitMovementStats.movement_queue.front()
	
	# Set correct animation for unit moving
	unit.animation_movement.get_direction_to_face(starting_cell, destination_cell)
	
	# Move Unit and smooth it out over time
	if abs(unit.position.x - destination_cell.position.x) >= 0.75 || abs(unit.position.y - destination_cell.position.y) >= 0.75:
		unit.position.x += (destination_cell.position.x - starting_cell.position.x) * unit.get_node("Animation").movement_animation_speed * delta
		unit.position.y += (destination_cell.position.y - starting_cell.position.y) * unit.get_node("Animation").movement_animation_speed * delta
	else:
		# Finalize movement to prevent rounding errors
		unit.position.x = destination_cell.position.x
		unit.position.y = destination_cell.position.y
		unit.UnitMovementStats.currentTile = destination_cell
		
		# Remove the tile in the queue
		unit.UnitMovementStats.movement_queue.pop_front()
	
	# Check if we have no more moves left in the queue
	if unit.UnitMovementStats.movement_queue.empty():
		# Stop moving
		is_moving = false
		
		# Set the new current tile
		unit.UnitMovementStats.currentTile.occupyingUnit = null
		unit.UnitMovementStats.currentTile = destination_cell
		unit.UnitMovementStats.currentTile.occupyingUnit = unit
		