extends Node2D

# Type of AI | Default is passive
enum {AGGRESIVE, PASSIVE, PATROL, HEAL, RANDOM}
var ai_type = AGGRESIVE

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
	var attack_this_target = all_attackable_enemies.pop_front()
	
	# Always attack Eirika if we find her
	for ally_unit in all_attackable_enemies:
		var threat_value = 0
		if ally_unit.UnitStats.name == "Eirika":
			return ally_unit
		
		# Check HP Amount -> Lower percentage enemies = higher threat
		threat_value += (100 - ((ally_unit.UnitStats.current_health / ally_unit.UnitStats.max_health) * 100))
		
		# Attack Type
		# Physical Damage
		print(get_parent().UnitInventory.current_item_equipped.weapon_type)
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
	
	# Should have found the enemy to attack
	return attack_this_target

# Find tile to move to
func find_tile_to_move_to(Unit_To_Move_Toward):
	# Figure out the algorithm to get there
	
	# Find out which tile we can move around the unit
	var allowed_tiles = []
	for tile in Unit_To_Move_Toward.UnitMovementStats.currentTile.adjCells:
		if get_parent().UnitMovementStats.allowedMovement.has(tile):
			allowed_tiles.append(tile)
	
	# Calculate the best tile to go to
	var best_tile = allowed_tiles[0]
	var best_tile_value = 0
	
	for tile_check in allowed_tiles:
		var tile_value = (tile_check.avoidanceBonus + tile_check.defenseBonus)
		 
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
	var final_movement_queue = []
	while !get_parent().UnitMovementStats.movement_queue.empty():
		var test_tile = get_parent().UnitMovementStats.movement_queue.pop_front()
		if get_parent().UnitMovementStats.allowedMovement.has(test_tile) && test_tile.occupyingUnit == null:
			final_movement_queue.push_back(test_tile)
	get_parent().UnitMovementStats.movement_queue = final_movement_queue
	
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
	# All AI will find all enemies that can be attacked, regardless of status
	calculate_move_sets()
	find_all_enemies_within_range()
	
	# Match the type of enemy
	match ai_type:
		AGGRESIVE:
			# Move toward Eirika if there are no enemies to attack
			if all_attackable_enemies.empty():
				find_tile_to_move_to_no_enemies()
			else:
				# Find unit to attack
				find_tile_to_move_to(find_most_threatening_enemy())
		PASSIVE:
			# Check if there are any enemies within range that we can attack
			if all_attackable_enemies.empty():
				get_parent().UnitActionStatus.set_current_action(Unit_Action_Status.DONE)
			else:
				# Find unit to attack
				find_tile_to_move_to(find_most_threatening_enemy())
		PATROL:
			# Check if there are any enemies within range that we can attack
			if all_attackable_enemies.empty():
				print("Moving to other destination")
			else:
				print("finding enemy to attack")
		HEAL:
			pass
		RANDOM:
			pass
