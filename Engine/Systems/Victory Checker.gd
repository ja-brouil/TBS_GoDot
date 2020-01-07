extends Node

class_name Victory_Checker

# This class will check if you have won the game and do what is it needed to move on to the next level

# States
enum {ELIMINATE_ALL_ENEMIES, SURVIVE, ESCORT, ASSASSINATE, SEIZE}
var victory_condition_state

# Survive
var turns_left_to_survive = 0

# Eliminate all enemies
# Use the battlefield enemy array

# Escort
var unit_to_escort
var tile_to_escort

# Assassinate
var unit_to_assassinate

func check_victory_status():
	match victory_condition_state:
		ELIMINATE_ALL_ENEMIES:
			if BattlefieldInfo.enemy_units.empty():
				BattlefieldInfo.victory = true
		SURVIVE:
			if turns_left_to_survive == BattlefieldInfo.turn_manager.player_turn_number:
				BattlefieldInfo.victory = true
		ESCORT:
			if unit_to_escort.UnitMovementStats.currentTile == tile_to_escort:
				BattlefieldInfo.victory = true
		ASSASSINATE:
			if !BattlefieldInfo.enemy_units.has(unit_to_assassinate):
				BattlefieldInfo.victory = true
		SEIZE:
			pass # Will have to determine how to do this best. Maybe just do escort?


func clear():
	# Reset variables
	turns_left_to_survive = 0
	unit_to_assassinate = null
	unit_to_escort = null
	tile_to_escort = null