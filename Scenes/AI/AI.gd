extends Node2D

# Type of AI | Default is passive
# Strings AGGRESIVE, PASSIVE, PATROL, HEAL, RANDOM | -> Make sure its all lowercase
var ai_type = "Aggresive"

# Holds all attackable enemies
var all_attackable_enemies = []

# Holds all healable enemies within range
var all_healable_enemies = []

# Patrol type of AI
var tile_to_walk_to
var tile_to_walk_from

# State
enum {ATTACK, HEAL, MOVE, NOTHING}
var current_state = NOTHING

# Player Attack
var player_unit_target

func process_ai():
	print("FROM AI SCRIPT: PROCESSING BANDIT NAME: ", get_parent().UnitStats.identifier)
	current_state = NOTHING
	$Timer.start(0)
	
# Helper Functions
# Calculate Movesets
func calculate_move_sets():
	BattlefieldInfo.movement_calculator.calculatePossibleMoves(get_parent(), BattlefieldInfo.grid)

# Find all enemies that the unit can attack | Takes into account the ranged weapon currently used
func find_all_enemies_within_range():
	# Clear the array
	all_attackable_enemies.clear()
	
	# Process Red Tiles
	for red_tile in get_parent().UnitMovementStats.allowedAttackRange:
		if red_tile.occupyingUnit != null && red_tile.occupyingUnit.UnitMovementStats.is_ally:
			var weapon = get_parent().UnitInventory
			var queue = []
			queue.append([weapon.MAX_ATTACK_RANGE, red_tile.occupyingUnit.UnitMovementStats.currentTile])
			while !queue.empty():
				# Pop first tile
				var check_tile = queue.pop_front()
				
				# Check if the tile is NOT occupied
				if check_tile[1].occupyingUnit == null:
					# Is the tile part of the blue tiles we can go to
					if Calculators.get_distance_between_two_tiles(check_tile[1], red_tile.occupyingUnit.UnitMovementStats.currentTile) >= weapon.MIN_ATTACK_RANGE && get_parent().UnitMovementStats.allowedMovement.has(check_tile[1]):
						# Add Enemy
						if !all_attackable_enemies.has(red_tile.occupyingUnit):
							all_attackable_enemies.append(red_tile.occupyingUnit)
				
				# If tile is occupied and it's ourselves
				if check_tile[1].occupyingUnit != null && check_tile[1].occupyingUnit == get_parent():
					if Calculators.get_distance_between_two_tiles(check_tile[1], red_tile.occupyingUnit.UnitMovementStats.currentTile) >= weapon.MIN_ATTACK_RANGE && get_parent().UnitMovementStats.allowedMovement.has(check_tile[1]):
						# Add Enemy
						if !all_attackable_enemies.has(red_tile.occupyingUnit):
							all_attackable_enemies.append(red_tile.occupyingUnit)
				
				# Tile was empty or we can't go there | Don't process anymore if the queue is empty
				for adjTile in check_tile[1].adjCells:
					var next_cost = check_tile[0] - 1
					if next_cost >= 0:
						queue.append([next_cost, adjTile])
	
	# Attack state
	if all_attackable_enemies.size() > 0:
		current_state = ATTACK

# Find all enemies that can be healed | Change later
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
	
	# Find unit to attack
	for ally_unit in all_attackable_enemies:
		var threat_value = 0
		
		# Small incentive to attack Eirika
		if ally_unit.UnitStats.name == "Eirika":
			threat_value += 5

		
		# Check HP Amount -> Lower percentage enemies = higher threat
		threat_value += (100 - ((ally_unit.UnitStats.current_health / ally_unit.UnitStats.max_health) * 100))
		
		# Attack Type
		# Physical Damage
		if get_parent().UnitInventory.current_item_equipped.item_class == Item.ITEM_CLASS.PHYSICAL:
			# Check Physical Defense -> Avoid enemies with higher def
			threat_value -= (ally_unit.UnitStats.def / 2)
			
		# Magic Damage
		elif get_parent().UnitInventory.current_item_equipped.item_class == Item.ITEM_CLASS.MAGIC:
			# Check Magical Defense -> Avoid enemies with higher res
			threat_value -= (ally_unit.UnitStats.res / 2)
		
		# Get Speed and Luck values (half these) Avoid enemies who can dodge very well
		threat_value -= ((ally_unit.UnitStats.luck + ally_unit.UnitStats.speed) / 2)
		
		# Check who is strong attack wise and go for them
		threat_value -= (ally_unit.UnitStats.strength + ally_unit.UnitStats.magic) / 2
		
		# Check if this new unit is worth more
		if (threat_value > most_threat_value):
			most_threat_value = threat_value
			attack_this_target = ally_unit
	
	# Should have found the enemy to attack
	player_unit_target = attack_this_target
	return attack_this_target

# Find tile to move to
func find_tile_to_move_to(Unit_To_Move_Toward):
	# Get all adjencent tiles
	var allowed_tiles = []
	# Get all possible tiles that we can attack this unit to
	var weapon = get_parent().UnitInventory
	var queue = []
	queue.append([weapon.MAX_ATTACK_RANGE, Unit_To_Move_Toward.UnitMovementStats.currentTile])
	while !queue.empty():
		# Pop first tile
		var check_tile = queue.pop_front()
		# Check if the tile is NOT occupied
		if check_tile[1].occupyingUnit == null:
			# Is the tile part of the blue tiles we can go to
			if Calculators.get_distance_between_two_tiles(check_tile[1], Unit_To_Move_Toward.UnitMovementStats.currentTile) >= weapon.MIN_ATTACK_RANGE && get_parent().UnitMovementStats.allowedMovement.has(check_tile[1]):
				# Add Possible Tile
				if !allowed_tiles.has(check_tile[1]):
					allowed_tiles.append(check_tile[1])
		
		# If tile is occupied and if it's ourselves
		if check_tile[1].occupyingUnit != null && check_tile[1].occupyingUnit == get_parent():
			# Is the tile part of the blue tiles we can go to
			if Calculators.get_distance_between_two_tiles(check_tile[1], Unit_To_Move_Toward.UnitMovementStats.currentTile) >= weapon.MIN_ATTACK_RANGE && get_parent().UnitMovementStats.allowedMovement.has(check_tile[1]):
				# Add Possible Tile
				if !allowed_tiles.has(check_tile[1]):
					allowed_tiles.append(check_tile[1])
		
		# Tile was empty or we can't go there | Don't process anymore if the queue is empty
		for adjTile in check_tile[1].adjCells:
			var next_cost = check_tile[0] - 1
			if next_cost >= 0:
				queue.append([next_cost, adjTile])
	
	get_best_tile_to_go_to(allowed_tiles, weapon)

func get_best_tile_to_go_to(allowed_tiles, weapon):
	# Calculate the best tile to go to
	var best_tile = allowed_tiles.front()
	var best_tile_value = 0
	
	for tile_check in allowed_tiles:
		var tile_value = 0
		
		tile_value = (tile_check.avoidanceBonus + tile_check.defenseBonus) + ((Calculators.get_distance_between_two_tiles(player_unit_target.UnitMovementStats.currentTile, tile_check) * 100))
		 
		if tile_value > best_tile_value:
			best_tile = tile_check
			best_tile_value = tile_value
	
	# Set the best weapon to use
	var distance_between_tile_target_and_enemy_to_attack = Calculators.get_distance_between_two_tiles(player_unit_target.UnitMovementStats.currentTile, best_tile)
	var highest_might = 0
	var best_item = null
	for item_weapon in weapon.inventory:
		# Check if we can use this weapon given the range
		if item_weapon.is_usable_by_current_unit && (item_weapon.max_range <= distance_between_tile_target_and_enemy_to_attack || item_weapon.min_range >= distance_between_tile_target_and_enemy_to_attack):
			if item_weapon.might > highest_might:
				best_item = item_weapon
				highest_might = best_item.might
	
	# Equip weapon || if not null
	if best_item != null:
		weapon.current_item_equipped = best_item
		
	# Check if we are going to the same tile
	if best_tile == get_parent().UnitMovementStats.currentTile:
		get_parent().UnitMovementStats.movement_queue.push_front(BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE])
		
		# Turn off tiles
		BattlefieldInfo.movement_calculator.turn_off_all_tiles(get_parent(), BattlefieldInfo.grid)
		
		# Emit signal to update the cells
		BattlefieldInfo.current_Unit_Selected = get_parent()
		next_step()
	else:
		# Move toward the target cell
		BattlefieldInfo.movement_calculator.get_path_to_destination(get_parent(), best_tile, BattlefieldInfo.grid)
		
		# Remove the unit's occupied status on the grid
		get_parent().UnitMovementStats.currentTile.occupyingUnit = null
		
		# Start moving the unit
		BattlefieldInfo.unit_movement_system.is_moving = true
		
		# Set Camera on unit
		BattlefieldInfo.current_Unit_Selected = get_parent()
		BattlefieldInfo.main_game_camera.position = (BattlefieldInfo.current_Unit_Selected.position + Vector2(-112, -82))

# Find best tile to move to if there is nothing to attack within range
func find_tile_to_move_to_no_enemies():
	# Figure out in the queue until the tile you can move is part of the moveset that you can go to
	var eirika_tile = BattlefieldInfo.ally_units["Eirika"].UnitMovementStats.currentTile
	
	# Create the path to that tile
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(get_parent(), eirika_tile, BattlefieldInfo.grid)
	
	# Work backwards until we have a tile that is part of the system
	var test_tile
	while !get_parent().UnitMovementStats.movement_queue.empty():
		test_tile = get_parent().UnitMovementStats.movement_queue.pop_back()
		if get_parent().UnitMovementStats.allowedMovement.has(test_tile) && test_tile.occupyingUnit == null:
			# The tile we want to go to is the test tile
			break
	
	
	# Prevent null errors if you can't go anywhere for some reason
	if get_parent().UnitMovementStats.movement_queue.empty():
		get_parent().UnitMovementStats.movement_queue.append(get_parent().UnitMovementStats.currentTile)
	else:
		get_parent().UnitMovementStats.movement_queue.clear()
		BattlefieldInfo.movement_calculator.get_path_to_destination(get_parent(), test_tile, BattlefieldInfo.grid)
	
	# Move to the target
	# Remove the unit's occupied status on the grid
	get_parent().UnitMovementStats.currentTile.occupyingUnit = null
	
	# Start moving the unit
	BattlefieldInfo.unit_movement_system.is_moving = true
	
	# Set Camera on unit
	BattlefieldInfo.current_Unit_Selected = get_parent()
	BattlefieldInfo.main_game_camera.position = (BattlefieldInfo.current_Unit_Selected.position + Vector2(-112, -82))
	
	# Set to move
	current_state = MOVE

# After moving
func next_step():
	match current_state:
		ATTACK:
			# Attack the enemy!
			BattlefieldInfo.combat_player_unit = player_unit_target
			BattlefieldInfo.combat_ai_unit = get_parent()
			BattlefieldInfo.turn_manager.turn = Turn_Manager.ENEMY_COMBAT_TURN
			BattlefieldInfo.start_ai_combat()
		MOVE:
			get_parent().UnitActionStatus.set_current_action(Unit_Action_Status.DONE)
			BattlefieldInfo.movement_calculator.turn_off_all_tiles(get_parent(), BattlefieldInfo.grid)
			get_parent().turn_greyscale_on()
			# Move to the next enemy
			BattlefieldInfo.turn_manager.turn = Turn_Manager.ENEMY_TURN
			BattlefieldInfo.turn_manager.emit_signal("check_end_turn")
		HEAL:
			pass # Process heal here

# AI Script
func _on_Timer_timeout():
	# If we have no weapons left to use, we surrender
	if get_parent().UnitInventory.current_item_equipped.item_name == "Unarmed":
		get_parent().UnitActionStatus.set_current_action(Unit_Action_Status.DONE)
		# Move to the next enemy
		BattlefieldInfo.turn_manager.turn = Turn_Manager.ENEMY_TURN
		return
	
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
				BattlefieldInfo.turn_manager.emit_signal("check_end_turn")
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
			# If unit to heal -> set to heal state
			# If nothing to heal -> find enemy that is injured and move toward them
			pass
		"Random":
			# If no enemies around, pick random spot and move there
			# If enemies -> attack them
			pass
