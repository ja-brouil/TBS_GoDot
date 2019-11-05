extends Node

# This class controls the system needed to pass between enemies and allies
class_name Turn_Manager

# States
enum {PLAYER_TURN, ENEMY_TURN, WAIT}
var turn

# Signal to play graphic
signal play_transition

func _init():
	turn = PLAYER_TURN


func _process(delta):
	check_end_of_turn()

# Ally
func reset_allys():
	for ally_unit in BattlefieldInfo.ally_units:
		ally_unit.UnitActionStatus.set_current_action(Unit_Action_Status.MOVE)

# Enemy
func reset_enemies():
	for enemy_unit in BattlefieldInfo.enemy_units:
		enemy_unit.UnitActionStatus.set_current_action(Unit_Action_Status.MOVE)

# Remove Greyscale
func reset_greyscale():
	for ally_unit in BattlefieldInfo.ally_units:
		ally_unit.turn_greyscale_off()
	
	for enemy_unit in BattlefieldInfo.enemy_units:
		enemy_unit.turn_greyscale_off()

# Not really a fan of checking this every frame but it will do for now. Optimize this later.
func check_end_of_turn():
	match turn:
		PLAYER_TURN:
			for ally_unit in BattlefieldInfo.ally_units:
				if ally_unit.UnitActionStatus.get_current_action() != Unit_Action_Status.DONE:
					return
			# All Units have moved and are done
			emit_signal("play_transition", "Enemy")
			reset_greyscale()
			turn = WAIT
		ENEMY_TURN:
			for enemy_unit in BattlefieldInfo.enemy_units:
				if enemy_unit.UnitActionStatus.get_current_action() != Unit_Action_Status.DONE:
					BattlefieldInfo.next_ai(enemy_unit)
					turn = WAIT
					return
			# All units have moved and are done
			emit_signal("play_transition", "Ally")
			reset_greyscale()
			turn = WAIT

# Ally turn
# reset all allies to active
# Check if all the allies are on done status
# if they are -> turn over to enemy turn

# Enemy Turn
# Set all enemies to active
# Process all aggresive enemies
# process all passive enemies
# process all healers
# are we done processing all enemies?