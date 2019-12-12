extends Node

# Controls the movement system for the units
class_name Unit_Movement_System_Cinematic

# On/off
var is_moving = false

# Array of units to move
var unit_to_move_same_time = []

# Update the world info
signal unit_finished_moving_cinema
signal individual_unit_finished_moving

func process_movement(delta):
	if !is_moving:
		return
	
	# Variables needed to move the units
	for unit_to_move in unit_to_move_same_time:
		var unit = unit_to_move
		var starting_cell = unit.UnitMovementStats.currentTile
		var destination_cell = unit.UnitMovementStats.movement_queue.front()
		
		# Set correct animation for unit moving
		unit.get_node("Animation").current_animation = unit.get_direction_to_face(starting_cell, destination_cell)
		
		# Move Unit and smooth it out over time
		if abs(unit.position.x - destination_cell.position.x) >= 0.75 || abs(unit.position.y - destination_cell.position.y) >= 0.75:
			unit.position.x += (destination_cell.position.x - starting_cell.position.x) * unit.animation_movement_speed * delta
			unit.position.y += (destination_cell.position.y - starting_cell.position.y) * unit.animation_movement_speed * delta
		else:
			# Finalize movement to prevent rounding errors
			unit.position.x = destination_cell.position.x
			unit.position.y = destination_cell.position.y
			unit.UnitMovementStats.currentTile = destination_cell
			
			# Remove the tile in the queue
			unit.UnitMovementStats.movement_queue.pop_front()
		
		# Prevent weird bug when the FPS drops or game is paused
		if abs(unit.position.x - destination_cell.position.x) >= 16 || abs(unit.position.y - destination_cell.position.y) >= 16:
			# Finalize movement to prevent rounding errors
			unit.position.x = destination_cell.position.x
			unit.position.y = destination_cell.position.y
			unit.UnitMovementStats.currentTile = destination_cell
			
			# Remove the tile in the queue
			unit.UnitMovementStats.movement_queue.pop_front()
		
		# Check if we have no more moves left in the queue
		if unit.UnitMovementStats.movement_queue.empty():
			
			# Set the new current tile and update the world tiles
			var h = unit.UnitMovementStats.currentTile 
			unit.UnitMovementStats.currentTile = destination_cell
			unit.UnitMovementStats.currentTile.occupyingUnit = unit
			
			# Turn off tiles
			BattlefieldInfo.movement_calculator.turn_off_all_tiles(unit, BattlefieldInfo.grid)
			
			# Set to Idle for animation
			unit.get_node("Animation").current_animation = "Idle"
			
			# SINGLE unit is done moving
			emit_signal("individual_unit_finished_moving", unit)
			
			# Remove unit from the array and check if it's empty
			unit_to_move_same_time.erase(unit)
			
	# All Units have moved, check if empty
	if unit_to_move_same_time.empty():
		BattlefieldInfo.main_game_camera.current = true
		is_moving = false
		emit_signal("unit_finished_moving_cinema")