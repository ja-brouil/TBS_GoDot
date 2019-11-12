extends Node2D

# Type of AI | Default is passive
# Strings AGGRESIVE, PASSIVE, PATROL, HEAL, RANGED, RANDOM | -> Make sure its all lowercase
var ai_type = "Aggresive"

# Holds all attackable enemies
var all_attackable_enemies = []

# Holds all healable enemies within range
var all_healable_enemies = []

# Patrol type of AI
var tile_to_walk_to
var tile_to_walk_from

#	Unit.UnitMovementStats.allowedMovement.clear()
#	Unit.UnitMovementStats.allowedAttackRange.clear()
#	Unit.UnitMovementStats.allowedHealRange.clear()

func process_ai():
	$Timer.start(0.5)
	
# Helper Functions
# Calculate Movesets
func calculate_move_sets():
	BattlefieldInfo.movement_calculator.calculatePossibleMoves(get_parent(), BattlefieldInfo.grid)

# Find all enemies that the unit can attack
func find_all_enemies_within_range():
	# Clear the array
	all_attackable_enemies.clear()
	
	# Get all attackable enemies
	# Process Blue tiles first
	
	for blue_tile in get_parent().UnitMovementStats.allowedMovement:
		if blue_tile.occupyingUnit != null && blue_tile.occupyingUnit.UnitMovementStats.is_ally:
			all_attackable_enemies.append(blue_tile.occupyingUnit)
	
	# Process Red Tiles
	for red_tile in get_parent().UnitMovementStats.allowedAttackRange:
		if red_tile.occupyingUnit != null && red_tile.occupyingUnit.UnitMovementStats.is_ally:
			all_attackable_enemies.append(red_tile.occupyingUnit)

# Find all enemies that can be healed
func find_all_enemies_that_can_be_healed():
	# Clear array
	all_healable_enemies.clear()
	
	# Process Blue tiles first
	for blue_tile in get_parent().UnitMovementStats.allowedMovement:
		if blue_tile.occuypingUnit != null && !blue_tile.occupyingUnit.UnitMovementStats.is_ally:
			all_healable_enemies.append(blue_tile.occupyingUnit)
	
	# Process Red Tiles
	for red_tile in get_parent().UnitMovementStats.allowedAttackRange:
		if red_tile.occupyingUnit != null && !red_tile.occupyingUnit.UnitMovementStats.is_ally:
			all_healable_enemies.append(red_tile.occupyingUnit)
	
	# Process Green Tiles
	for green_tile in get_parent().UnitMovementStats.allowedHealkRange:
		if green_tile.occupyingUnit != null && !green_tile.occupyingUnit.UnitMovementStats.is_ally:
			all_healable_enemies.append(green_tile.occupyingUnit)
			

# Find the enemy to attack
func find_most_threatening_enemy():
	var most_threat_value = 0
	var attack_this_target = all_attackable_enemies.front()
	
	# Always attack Eirika if we find her
	for ally_unit in all_attackable_enemies:
		var threat_value = 0
		if ally_unit.UnitStats.name == "Eirika":
			# Check if we are already standing on an Eirika tile
			for eirika_adj_tile in ally_unit.UnitMovementStats.currentTile.adjCells:
				if get_parent().UnitMovementStats.currentTile == eirika_adj_tile:
					attack_eirika_and_move_away()
					return
			return ally_unit
		
		# Check HP Amount -> Lower percentage enemies = higher threat
		threat_value += (100 - ((ally_unit.UnitStats.current_health / ally_unit.UnitStats.max_health) * 100))
		
		# Attack Type
		# Physical Damage
		if get_parent().UnitInventory.current_item_equipped.weapon_type == Item.WEAPON_TYPE.WEAPON:
			# Check Physical Defense -> Avoid enemies with higher def
			threat_value -= (ally_unit.UnitStats.def / 2)
			
		# Magic Damage
		elif get_parent().UnitInventory.current_item_equipped.weapon_type == Item.WEAPON_TYPE.MAGIC:
			# Check Magical Defense -> Avoid enemies with higher res
			threat_value -= (ally_unit.UnitStats.res / 2)
		
		# Get Speed and Luck values (half these) Avoid enemies who can dodge very well
		threat_value -= ((ally_unit.UnitStats.luck + ally_unit.UnitStats.speed) / 2)
		
		# Check who is strong attack wise and go for them
		threat_value += (ally_unit.UnitStats.strength + ally_unit.UnitStats.magic)
		
		# Check if this new unit is worth more
		if (threat_value > most_threat_value):
			most_threat_value = threat_value
			attack_this_target = ally_unit
	
	# stop if the enemy list is empty
	if all_attackable_enemies.empty():
		find_tile_to_move_to_no_enemies()
		return
	
	# Should have found the enemy to attack
	return attack_this_target

# Find tile to move to | Melee  units
func find_tile_to_move_to(Unit_To_Move_Toward):
	# Get all adjencent tiles
	var allowed_tiles = []
	for tile in Unit_To_Move_Toward.UnitMovementStats.currentTile.adjCells:
		if get_parent().UnitMovementStats.allowedMovement.has(tile) && tile.occupyingUnit == null:
			allowed_tiles.append(tile)
	
	# Fall back in case there are no tiles available
	if allowed_tiles.empty():
		find_tile_to_move_to_no_enemies()
		return
	
	# Calculate the best tile to go to
	var best_tile = allowed_tiles.front()
	var best_tile_value = 0
	
	for tile_check in allowed_tiles:
		tile_check = allowed_tiles[0]
		var tile_value = 0
		
		tile_value = (tile_check.avoidanceBonus + tile_check.defenseBonus)
		 
		if tile_value > best_tile_value:
			best_tile = tile_check
			best_tile_value = tile_value
	
	# Move toward the target cell
	BattlefieldInfo.movement_calculator.get_path_to_destination(get_parent(), best_tile, BattlefieldInfo.grid)
	
	# Check if we are going to the same tile
	if best_tile == get_parent().UnitMovementStats.currentTile:
		get_parent().UnitMovementStats.movement_queue.push_front(BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE])
				
	# Remove the unit's occupied status on the grid
	get_parent().UnitMovementStats.currentTile.occupyingUnit = null
	
	# Start moving the unit
	BattlefieldInfo.unit_movement_system.is_moving = true
	
	# Set Camera on unit
	var movement_camera = preload("res://Scenes/Camera/MovementCamera.tscn").instance()
	BattlefieldInfo.current_Unit_Selected = get_parent()
	BattlefieldInfo.current_Unit_Selected.add_child(movement_camera)
	movement_camera.current = true

# Find best tile to move to if there is nothing to attack within range
func find_tile_to_move_to_no_enemies():
	# Figure out in the queue until the tile you can move is part of the moveset that you can go to
	var eirika_tile
	for ally_unit in BattlefieldInfo.ally_units:
		if ally_unit.UnitStats.name == "Eirika":
			eirika_tile = ally_unit.UnitMovementStats.currentTile
	
	# Create the path to that tile
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(get_parent(), eirika_tile, BattlefieldInfo.grid)
	
	# Work backwards until we have a tile that is part of the system
	while !get_parent().UnitMovementStats.movement_queue.empty():
		var test_tile = get_parent().UnitMovementStats.movement_queue.back()
		if get_parent().UnitMovementStats.allowedMovement.has(test_tile) && test_tile.occupyingUnit == null:
			get_parent().UnitMovementStats.allowedMovement.append(test_tile)
			break
		get_parent().UnitMovementStats.movement_queue.pop_back()
	
	# Prevent null errors if you can't go anywhere for some reason
	if get_parent().UnitMovementStats.movement_queue.empty():
		get_parent().UnitMovementStats.movement_queue.append(get_parent().UnitMovementStats.currentTile)
	
	# Move to the target
	# Remove the unit's occupied status on the grid
	get_parent().UnitMovementStats.currentTile.occupyingUnit = null
	
	# Start moving the unit
	BattlefieldInfo.unit_movement_system.is_moving = true
	
	# Set Camera on unit
	var movement_camera = preload("res://Scenes/Camera/MovementCamera.tscn").instance()
	BattlefieldInfo.current_Unit_Selected = get_parent()
	BattlefieldInfo.current_Unit_Selected.add_child(movement_camera)
	movement_camera.current = true

# Move away from Eirika if we are standing on an adj tile already
func attack_eirika_and_move_away():
	# Math for positions on the map
	var min_x = 0
	var min_y = 0
	var max_x = BattlefieldInfo.map_width - 1
	var max_y = BattlefieldInfo.map_height - 1
	var move_square = Vector2(0,0)
	
	# Attack then move
	print("FROM AI SCRIPT: Attacking Eirika then moving!")
	
	# Calculate X Distance
	if abs(min_x - (get_parent().position.x / Cell.CELL_SIZE)) >= abs(max_x - (get_parent().position.x / Cell.CELL_SIZE)):
		move_square.x = min_x
	else:
		move_square.x = max_x
	
	# Calcuate Y Distance
	if abs(min_y - (get_parent().position.y / Cell.CELL_SIZE)) >= abs(max_y - (get_parent().position.y / Cell.CELL_SIZE)):
		move_square.y = min_y
	else:
		move_square.y = max_y
	
	# Move to this tile
	# Create the path to that tile
	BattlefieldInfo.movement_calculator.get_path_to_destination(get_parent(), BattlefieldInfo.grid[move_square.x][move_square.y], BattlefieldInfo.grid)
	
	# Work backwards until we have a tile that is part of the system
	while !get_parent().UnitMovementStats.movement_queue.empty():
		var test_tile = get_parent().UnitMovementStats.movement_queue.back()
		if get_parent().UnitMovementStats.allowedMovement.has(test_tile) && test_tile.occupyingUnit == null:
			get_parent().UnitMovementStats.allowedMovement.append(test_tile)
			break
		get_parent().UnitMovementStats.movement_queue.pop_back()
	
	# Move to the target
	# Remove the unit's occupied status on the grid
	get_parent().UnitMovementStats.currentTile.occupyingUnit = null
	
	# Start moving the unit
	BattlefieldInfo.unit_movement_system.is_moving = true
	
	# Set Camera on unit
	var movement_camera = preload("res://Scenes/Camera/MovementCamera.tscn").instance()
	BattlefieldInfo.current_Unit_Selected = get_parent()
	BattlefieldInfo.current_Unit_Selected.add_child(movement_camera)
	movement_camera.current = true
	
# AI Script
func _on_Timer_timeout():
	# Print Bandit name
	print("FROM AI SCRIPT: PROCESSING BANDIT NAME: ", get_parent().UnitStats.name)
	
	# All AI will find all enemies that can be attacked, regardless of status
	calculate_move_sets()
	find_all_enemies_within_range()
	
	# Match the type of enemy
	match ai_type:
		"Aggresive":
			# Move toward Eirika if there are no enemies to attack
			if all_attackable_enemies.empty():
				find_tile_to_move_to_no_enemies()
			else:
				# Find unit to attack
				find_tile_to_move_to(find_most_threatening_enemy())
		"Passive":
			# Check if there are any enemies within range that we can attack
			if all_attackable_enemies.empty():
				get_parent().UnitActionStatus.set_current_action(Unit_Action_Status.DONE)
				BattlefieldInfo.movement_calculator.turn_off_all_tiles(get_parent(), BattlefieldInfo.grid)
				# Move to the next enemy
				BattlefieldInfo.turn_manager.turn = Turn_Manager.ENEMY_TURN
			else:
				# Find unit to attack
				find_tile_to_move_to(find_most_threatening_enemy())
		"Patrol":
			# Check if there are any enemies within range that we can attack
			if all_attackable_enemies.empty():
				print("Moving to other destination")
			else:
				print("finding enemy to attack")
		"Heal":
			pass
		"Random":
			pass