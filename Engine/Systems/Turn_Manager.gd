extends Node

# This class controls the system needed to pass between enemies and allies
class_name Turn_Manager

# States
enum {PLAYER_TURN, ENEMY_TURN, ENEMY_COMBAT_TURN, WAIT}
var turn

# Turn number
var player_turn_number = 1
var enemy_turn_number = 1

# Signal for events
signal player_turn_increased
signal enemy_turn_increased

# Signal to play graphic
signal play_transition

# Check for end of turn
signal check_end_turn

# Game Over
signal game_over

# Mid Level events I am not sure where to place this so this will have to do for now
var mid_level_events = []

func _init():
	turn = WAIT

func _ready():
	connect("check_end_turn", self, "check_end_of_turn")
	connect("game_over", self, "game_over_scene")

# Ally
func reset_allys():
	if BattlefieldInfo.save_load_system.is_loading_level:
		return
	
	for ally_unit in BattlefieldInfo.ally_units.values():
		ally_unit.UnitActionStatus.set_current_action(Unit_Action_Status.MOVE)

# Enemy
func reset_enemies():
	for enemy_unit in BattlefieldInfo.enemy_units.values():
		enemy_unit.UnitActionStatus.set_current_action(Unit_Action_Status.MOVE)

# Remove Greyscale
func reset_greyscale():
	if !BattlefieldInfo.save_load_system.is_loading_level:
		for ally_unit in BattlefieldInfo.ally_units.values():
			ally_unit.turn_greyscale_off()
	
	for enemy_unit in BattlefieldInfo.enemy_units.values():
		enemy_unit.turn_greyscale_off()

# Not really a fan of checking this every frame but it will do for now. Optimize this later.
func check_end_of_turn():
	# Check if we have won
	BattlefieldInfo.victory_system.check_victory_status()
	
	# We have beaten this level, move on to the next one
	if BattlefieldInfo.victory:
		turn = WAIT
		call_deferred("victory_next_level")
		BattlefieldInfo.victory = false
		BattlefieldInfo.cursor.disable_standard("h")
		return
	
	# If game over, exit this
	if BattlefieldInfo.game_over:
		turn = WAIT
		call_deferred("game_over_scene")
		BattlefieldInfo.game_over = false
		BattlefieldInfo.cursor.disable_standard("h")
		return
	
	match turn:
		PLAYER_TURN:
			for ally_unit in BattlefieldInfo.ally_units.values():
				if ally_unit.UnitActionStatus.get_current_action() != Unit_Action_Status.DONE:
					return
			# Increase the player turn amount by 1
			player_turn_number += 1
			turn = WAIT
			emit_signal("player_turn_increased", player_turn_number)
			
			# Run mid level events
			if mid_level_events.empty():
				start_ally_transition()
		ENEMY_TURN:
			for enemy_unit in BattlefieldInfo.enemy_units.values():
				if enemy_unit.UnitActionStatus.get_current_action() != Unit_Action_Status.DONE:
					turn = WAIT
					BattlefieldInfo.next_ai(enemy_unit)
					return
			# All Enemy units have moved and are done
			BattlefieldInfo.current_Unit_Selected = null
			
			# Increase the enemy turn amount by 1
			enemy_turn_number += 1
			turn = WAIT
			emit_signal("enemy_turn_increased", enemy_turn_number)
			
			# Start enemy transition
			if mid_level_events.empty():
				start_enemy_transition()
		WAIT:
			pass

func start_ally_transition():
	# All Ally Units have moved and are done
	$"End of Enemy".start(0)

func start_enemy_transition():
	# Set Camera back on Eirika and cursor
	move_camera_to_Eirika()
	# Start Transition
	$"End of Ally".start(0)

func _on_End_of_Ally_timeout():
	emit_signal("play_transition", "Ally")
	reset_greyscale()

func _on_End_of_Enemy_timeout():
	emit_signal("play_transition", "Enemy")
	reset_greyscale()

func reset():
	player_turn_number = 1
	enemy_turn_number = 1
	for event in mid_level_events:
		event.queue_free()
	mid_level_events.clear()

func game_over_scene():
	# Reset
	reset()
	
	# Stop input from cursor
	BattlefieldInfo.cursor.set_process_input(false)
	
	# Free current battlefield scene
	SceneTransition.change_scene("res://Scenes/Game Over/Game Over Screen.tscn", 2)

func victory_next_level():
	BattlefieldInfo.level_container.next_level()

func move_camera_to_Eirika():
	BattlefieldInfo.main_game_camera.position = (BattlefieldInfo.Eirika.position + Vector2(-112, -82))
	BattlefieldInfo.main_game_camera.clampCameraPosition()
	BattlefieldInfo.cursor.position = BattlefieldInfo.Eirika.position
	BattlefieldInfo.cursor.updateCursorData()
	BattlefieldInfo.cursor.emit_signal("cursorMoved", "left", BattlefieldInfo.cursor.position)
