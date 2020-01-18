extends Node2D

var ally_texture;
var enemy_texture;

func _ready():
	BattlefieldInfo.turn_manager.connect("play_transition", self, "start_transition")
	BattlefieldInfo.tile_unit_updater.connect("update_done", self, "finish_turn_transition")
	BattlefieldInfo.turn_transition = self

func start_level():
	# Level Start
	start_transition("Player")

func start_transition(type):
	if type == "Enemy":
		$"Enemy Phase".visible = true
		$"Animation_E".current_animation = "Move_Off"
		get_parent().get_parent().get_node("BattlefieldHUD").turn_off_battlefield_ui()
		BattlefieldInfo.cursor.cursor_state = Cursor.WAIT
	else:
#		BattlefieldInfo.music_player.get_node("EnemyLevel").stop()
		$"Player Turn".visible = true
		$"Animation".current_animation = "Move_Off"

# Update turn manager
func ally_animation_finished(anim_name):
	# Update tiles and units for ally
	BattlefieldInfo.tile_unit_updater.ally_turn_update()

func enemy_animation_finished(anim_name):
	# Update tiles and units for enemy
	BattlefieldInfo.tile_unit_updater.enemy_turn_update()

func finish_turn_transition(type):
	if type == "Ally":
		# Set to ally turn
		BattlefieldInfo.turn_manager.turn = Turn_Manager.PLAYER_TURN
		BattlefieldInfo.turn_manager.reset_allys()
		BattlefieldInfo.turn_manager.reset_enemies()
		
		# Activate UI and Cursor again
		get_parent().get_parent().get_node("BattlefieldHUD").turn_on_battlefield_ui()
		BattlefieldInfo.cursor.back_to_move()
	else:
		# Set to enemy turn
		BattlefieldInfo.turn_manager.turn = Turn_Manager.ENEMY_TURN
		BattlefieldInfo.turn_manager.reset_enemies()
		
		# Start AI
		BattlefieldInfo.turn_manager.emit_signal("check_end_turn")