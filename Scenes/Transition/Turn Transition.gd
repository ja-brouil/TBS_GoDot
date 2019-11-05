extends Node2D

var ally_texture;
var enemy_texture;

func _ready():
	BattlefieldInfo.turn_manager.connect("play_transition", self, "start_transition")
	
	# Level Start
	start_transition("Player")

func start_transition(type):
	if type == "Enemy":
		if BattlefieldInfo.enemy_units.size() <= 1:
			BattlefieldInfo.music_player.get_node("OneUnitLeft").stop()
		else:
			BattlefieldInfo.music_player.get_node("AllyLevel").stop()
		get_parent().get_parent().get_node("BattlefieldHUD").turn_off_battlefield_ui()
		get_parent().get_parent().get_node("Cursor").enable(false, Cursor.WAIT)
		$"Enemy Phase".visible = true
		$"Animation_E".current_animation = "Move_Off"
	else:
		BattlefieldInfo.music_player.get_node("EnemyLevel").stop()
		$"Player Turn".visible = true
		$"Animation".current_animation = "Move_Off"

# Update turn manager
func ally_animation_finished(anim_name):
	BattlefieldInfo.turn_manager.turn = Turn_Manager.PLAYER_TURN
	BattlefieldInfo.turn_manager.reset_allys()
	
	if BattlefieldInfo.enemy_units.size() <= 1:
		BattlefieldInfo.music_player.get_node("OneUnitLeft").play(0)
	else:
		BattlefieldInfo.music_player.get_node("AllyLevel").play(0)

func enemy_animation_finished(anim_name):
	BattlefieldInfo.turn_manager.turn = Turn_Manager.ENEMY_TURN
	BattlefieldInfo.turn_manager.reset_enemies()
	BattlefieldInfo.music_player.get_node("EnemyLevel").play(0)
