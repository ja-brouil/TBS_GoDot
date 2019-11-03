extends Node2D

var ally_texture;
var enemy_texture;

func _ready():
	BattlefieldInfo.turn_manager.connect("play_transition", self, "start_transition")

func start_transition(type):
	if type == "Enemy":
		get_parent().get_parent().get_node("BattlefieldHUD").turn_off_battlefield_ui()
		$"Enemy Phase".visible = true
		$"Animation_E".current_animation = "Move_Off"
	else:
		$"Player Turn".visible = true
		$"Animation".current_animation = "Move_Off"

# Update turn manager
func ally_animation_finished(anim_name):
	BattlefieldInfo.turn_manager.turn = Turn_Manager.ENEMY_TURN

func enemy_animation_finished(anim_name):
	BattlefieldInfo.turn_manager.turn = Turn_Manager.PLAYER_TURN