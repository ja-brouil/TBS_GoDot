# Movement Calculator for units
class_name MovementCalculator

# Calculate Movement Blue Squares
static func calculatePossibleMoves(Unit, AllTiles) -> void:
	# Clear the allowed tiles before calculation
	Unit.UnitMovementStats.allowedMovement.clear()
	Unit.UnitMovementStats.allowedAttackRange.clear()
	Unit.UnitMovementStats.allowedHealRange.clear()
	
	# Process Tiles
	processTile(Unit.UnitMovementStats.currentTile, Unit.UnitMovementStats, Unit.UnitMovementStats.movementSteps, Unit)
#
	# Light all the blue tiles -> Change this later to check if the unit has a healing ability and turn on green tiles
	for blueTile in Unit.UnitMovementStats.allowedMovement:
		AllTiles[blueTile.getPosition().x][blueTile.getPosition().y].get_node("MovementRangeRect").turnOn("Blue")

# Recursive function to find all movement tiles
static func processTile(initialTile, unit_movement, moveSteps, unit) -> void:
	# Add initial tile
	unit_movement.allowedMovement.append(initialTile)
	
	# Process the adj tiles
	for adjTile in initialTile.adjCells:
		# Calculate the cost of moving to the next tile
		var next_Move_Cost = moveSteps - adjTile.movementCost - getPenaltyCost(unit_movement, adjTile.tileName)
		
		# Do we have enough move to reach the next tile?
		if next_Move_Cost >= 0:
			# Allow passage through allied units # Add this later
			processTile(adjTile, unit_movement, next_Move_Cost, unit)

# Returns the penalty cost associated with the unit's class for moving across different tiles
static func getPenaltyCost(Unit_Movement, Cell_Type) -> int:
	match Cell_Type:
		"Plain" || "Road" || "Bridge" || "Throne":
			return Unit_Movement.defaultPenalty
		"Mountain":
			return Unit_Movement.mountainPenalty
		"Hill":
			return Unit_Movement.hillPenalty
		"Forest":
			return Unit_Movement.forestPenalty
		"Fortress":
			return Unit_Movement.fortressPenalty
		"Village":
			return Unit_Movement.buildingPenalty
		"River":
			return Unit_Movement.riverPenalty
		"Sea":
			return Unit_Movement.seaPenalty
		_:
			# fall through
			return 0

# Turn on or off all tiles
static func turn_off_all_tiles(Unit, AllTiles) -> void:
	# Turn off blue
	for blueTile in Unit.UnitMovementStats.allowedMovement:
		AllTiles[blueTile.getPosition().x][blueTile.getPosition().y].get_node("MovementRangeRect").turnOff("Blue")
	# Turn off Red -> TO DO
	
	# Turn off Green -> TO DO

# Find the shortest path to the target destination | This uses the A* algorithm
static func get_path_to_destination(Unit, target_destination, AllTiles):
	# Clear Tile statistics first
	for tile_array in AllTiles:
		for tile in tile_array:
			tile.parentTile = null
			tile.hCost = 0
			tile.gCost = 0
	
	# Clear Queue for the unit
	Unit.UnitMovementStats.movement_queue.clear()
	
	# Hashset and Priority Queue to hold all the tiles needed
	var closed_list = HashSet.new()
	var open_list = PriorityQueue.new()
	
	# Get Current Tile
	var current_tile = Unit.UnitMovementStats.currentTile
	
	# Add the current cell we are starting on to this list
	open_list.add_first(Unit.UnitMovementStats.currentTile)
	
	# Process Tiles until the open list is empty
	while open_list.get_size() > 0:
		# Remove the first tile in the list and add it to the closed list
		current_tile = open_list.pop_front()
		closed_list.add(current_tile)
		
		
		# Check if we have reached our destination
		if current_tile == target_destination:
			print("Destination has been found")
			break
		
		# Process Adj Tiles
		for adjCell in current_tile.adjCells:
			
			# Do not process unwalkable tiles
			if adjCell.movementCost >= 50 || closed_list.contains(adjCell):
				continue
			
			# Calculate Heuristic costs
			var movement_cost_to_neighbor = current_tile.gCost + adjCell.movementCost
			if movement_cost_to_neighbor < adjCell.gCost || !open_list.contains(adjCell):
				adjCell.gCost = movement_cost_to_neighbor
				adjCell.hCost = calculate_hCost(adjCell, target_destination, Unit, AllTiles)
				adjCell.parentTile = current_tile
				
				# Add to the open List
				open_list.add_first(adjCell)
	
	# Create the Pathfinding Queue
	create_pathfinding_queue(target_destination, Unit)


# Calculates the H Costs based on how far you need to go
static func calculate_hCost(initial_tile, destination_tile, unit, all_tiles) -> int:
	var MovementStats = unit.UnitMovementStats
	var starting_NodeX = initial_tile.getPosition().x
	var starting_NodeY = initial_tile.getPosition().y
	var total_vertical_cost = 0
	var total_horizontal_cost = 0
	
	# Which direction has more tiles to traverse to the destination
	if starting_NodeX > starting_NodeY:
		# North South
		var vertical_movement = 1
		if destination_tile.getPosition().y - destination_tile.getPosition().y < 0:
			vertical_movement = -1
		elif destination_tile.getPosition().y - destination_tile.getPosition().y == 0:
			vertical_movement = 0
		
		# Calculate the difference 
		for i in range(vertical_tile_amount(initial_tile, destination_tile)):
			total_vertical_cost += all_tiles[starting_NodeX][starting_NodeY + vertical_movement].movementCost + getPenaltyCost(MovementStats, all_tiles[starting_NodeX][starting_NodeY + vertical_movement].tileName)
		
		# West East
		var horizontal_movement = 1
		if destination_tile.getPosition().x - destination_tile.getPosition().x < 0:
			horizontal_movement = -1
		elif destination_tile.getPosition().x - destination_tile.getPosition().x == 0:
			horizontal_movement = 0
		
		# Calculate the differences
		for i in range(horizontal_tile_amount(initial_tile, destination_tile)):
			total_horizontal_cost += all_tiles[starting_NodeX + horizontal_movement][starting_NodeY].movementCost + getPenaltyCost(MovementStats, all_tiles[starting_NodeX + horizontal_movement][starting_NodeY].tileName)
		
	else:
		# West East
		var horizontal_movement = 1
		if destination_tile.getPosition().x - destination_tile.getPosition().x < 0:
			horizontal_movement = -1
		elif destination_tile.getPosition().x - destination_tile.getPosition().x == 0:
			horizontal_movement = 0
		
		# Calculate the differences
		for i in range(horizontal_tile_amount(initial_tile, destination_tile)):
			total_horizontal_cost += all_tiles[starting_NodeX + horizontal_movement][starting_NodeY].movementCost + getPenaltyCost(unit.UnitMovementStats, all_tiles[starting_NodeX + horizontal_movement][starting_NodeY].tileName)
	# North South
		var vertical_movement = 1
		if destination_tile.getPosition().y - destination_tile.getPosition().y < 0:
			vertical_movement = -1
		elif destination_tile.getPosition().y - destination_tile.getPosition().y == 0:
			vertical_movement = 0
		
		# Calculate the difference 
		for i in range(vertical_tile_amount(initial_tile, destination_tile)):
			total_vertical_cost += all_tiles[starting_NodeX][starting_NodeY + vertical_movement].movementCost + getPenaltyCost(unit.UnitMovementStats, all_tiles[starting_NodeX][starting_NodeY + vertical_movement].tileName)
	
	return total_horizontal_cost + total_vertical_cost

# Returns how many tiles are between the target and initial for vertical amount
static func vertical_tile_amount(initial_cell, destination_cell) -> int:
	return abs(initial_cell.getPosition().y - destination_cell.getPosition().y) as int

# Returns how many tiles are between the target and initial for horizontal amount
static func horizontal_tile_amount(initial_cell, destination_cell) -> int:
	return abs(initial_cell.getPosition().x - destination_cell.getPosition().x) as int

# Create the pathfinding queue needed for the unit to move there
static func create_pathfinding_queue(destination_cell, unit) -> void:
	# Get the Queue
	var MovementStatsQueue = unit.UnitMovementStats.movement_queue
	
	var next_cell = destination_cell
	var starting_cell = unit.UnitMovementStats.currentTile
	
	
	for i in range(5):
		MovementStatsQueue.push_front(next_cell)
		next_cell = next_cell.parentTile
	
#	while next_cell != starting_cell:
#		MovementStatsQueue.push_front(next_cell)
#		next_cell = next_cell.parentTile
	
	# Print Path
	for tile in MovementStatsQueue:
		print(tile.toString())

# Check if move is valid
static func check_if_move_is_valid(destination_cell, unit) -> bool:
	return unit.UnitMovementStats.allowedMovement.has(destination_cell)