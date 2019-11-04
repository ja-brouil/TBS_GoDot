extends Node2D

# Type of AI | Default is passive
enum {AGGRESIVE, PASSIVE, PATROL, HEAL}
var ai_type = PASSIVE

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
	# All AI will find all enemies that can be attacked, regardless of status
	calculate_move_sets()
	find_all_enemies_within_range()
	
	# Match the type of enemy
	match ai_type:
		AGGRESIVE:
			pass
		PASSIVE:
			# Check if there are any enemies within range that we can attack
			if all_attackable_enemies.empty():
				get_parent().UnitActionStatus.set_current_action(Unit_Action_Status.DONE)
			else:
				print("finding unit to attack")
		PATROL:
			# Check if there are any enemies within range that we can attack
			if all_attackable_enemies.empty():
				print("Moving to other destination")
			else:
				print("finding enemy to attack")
		HEAL:
			pass

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
		if blue_tile.occuypingUnit != null && blue_tile.occupyingUnit.UnitMovementStats.isAlly:
			all_attackable_enemies.append(blue_tile.occupyingUnit)
	
	# Process Red Tiles
	for red_tile in get_parent().UnitMovementStats.allowedAttackRange:
		if red_tile.occupyingUnit != null && red_tile.occupyingUnit.UnitMovementStats.isAlly:
			all_attackable_enemies.append(red_tile.occupyingUnit)

# Find all enemies that can be healed
func find_all_enemies_that_can_be_healed():
	# Clear array
	all_healable_enemies.clear()
	
	# Process Blue tiles first
	for blue_tile in get_parent().UnitMovementStats.allowedMovement:
		if blue_tile.occuypingUnit != null && !blue_tile.occupyingUnit.UnitMovementStats.isAlly:
			all_healable_enemies.append(blue_tile.occupyingUnit)
	
	# Process Red Tiles
	for red_tile in get_parent().UnitMovementStats.allowedAttackRange:
		if red_tile.occupyingUnit != null && !red_tile.occupyingUnit.UnitMovementStats.isAlly:
			all_healable_enemies.append(red_tile.occupyingUnit)
	
	# Process Green Tiles
	for green_tile in get_parent().UnitMovementStats.allowedHealkRange:
		if green_tile.occupyingUnit != null && !green_tile.occupyingUnit.UnitMovementStats.isAlly:
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
		if get_parent().UnitInventory.current_item_equipped.weapon_type == Item.WEAPON:
			# Check Physical Defense -> Avoid enemies with higher def
			threat_value -= (ally_unit.UnitStats.def / 2)
			
		# Magic Damage
		elif get_parent().UnitInventory.current_item_equipped.weapon_type == Item.MAGIC:
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