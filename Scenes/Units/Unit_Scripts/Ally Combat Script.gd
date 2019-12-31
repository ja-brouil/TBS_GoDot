extends "res://Scenes/Units/Unit_Scripts/Combat Unit.gd"

signal play_enemy_dodge_anim

var game_over_scene = preload("res://Scenes/Game Over/Game Over Screen.tscn")

func play_miss_sound():
	var random = int(rand_range(1,3))
	BattlefieldInfo.battle_sounds.get_node(str("Attack Miss ", random)).play(0)
	# Play Miss anim
	emit_signal("play_enemy_dodge_anim")

func death_anim_signal():
	emit_signal("death_anim_done")

# This will only be called when Eirika dies for this animation
func game_over():
	# Stop Music
	BattlefieldInfo.music_player.get_node("AllyLevel").stop()
	
	# Stop Turn Manager
	BattlefieldInfo.turn_manager.turn = Turn_Manager.WAIT
	
	SceneTransition.change_scene(game_over_scene, 1)