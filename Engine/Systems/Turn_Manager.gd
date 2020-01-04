extends Node

# This class controls the system needed to pass between enemies and allies
class_name Turn_Manager

# States
enum {PLAYER_TURN, ENEMY_TURN, ENEMY_COMBAT_TURN, WAIT}
var turn

# Turn number
var player_turn_number = 0
var enemy_turn_number = 0

# Signal for events
signal player_turn_increased
signal enemy_turn_increased

# Signal to play graphic
signal play_transition

# Mid Level events I am not sure where to place this so this will have to do for now
var mid_level_events = []

# Test fix
var gg

func _init():
	turn = WAIT

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
	# If game over, exit this
	if BattlefieldInfo.game_over:
		turn = WAIT
		set_process(false)
		call_deferred("game_over_scene")
		return
	
	match turn:
		PLAYER_TURN:
			for ally_unit in BattlefieldInfo.ally_units:
				if ally_unit.UnitActionStatus.get_current_action() != Unit_Action_Status.DONE:
					return
			# Increase the player turn amount by 1
			player_turn_number += 1
			emit_signal("player_turn_increased", player_turn_number)
			
			# Run mid level events
			if mid_level_events.empty():
				start_ally_transition()
			
			turn = WAIT
		ENEMY_TURN:
			for enemy_unit in BattlefieldInfo.enemy_units:
				if enemy_unit.UnitActionStatus.get_current_action() != Unit_Action_Status.DONE:
					turn = WAIT
					BattlefieldInfo.next_ai(enemy_unit)
					return
			# All Enemy units have moved and are done
			BattlefieldInfo.current_Unit_Selected = null
			
			# Increase the enemy turn amount by 1
			enemy_turn_number += 1
			emit_signal("enemy_turn_increased", enemy_turn_number)
			
			# Start enemy transition
			if mid_level_events.empty():
				start_enemy_transition()
			
			turn = WAIT
		WAIT:
			pass

func start_ally_transition():
	# All Ally Units have moved and are done
	$"End of Enemy".start(0)

func start_enemy_transition():
	# Set Camera back on Eirika and cursor
	BattlefieldInfo.main_game_camera.position = (BattlefieldInfo.Eirika.position + Vector2(-112, -82))
	BattlefieldInfo.main_game_camera.clampCameraPosition()
	BattlefieldInfo.cursor.position = BattlefieldInfo.Eirika.position
	# Start Transition
	$"End of Ally".start(0)

func _on_End_of_Ally_timeout():
	emit_signal("play_transition", "Ally")
	reset_greyscale()

func _on_End_of_Enemy_timeout():
	emit_signal("play_transition", "Enemy")
	reset_greyscale()

func game_over_scene():
	# Free current battlefield scene
	gg = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	SceneTransition.manual_swap_scene(gg,"res://Scenes/Game Over/Game Over Screen.tscn", 0.1)