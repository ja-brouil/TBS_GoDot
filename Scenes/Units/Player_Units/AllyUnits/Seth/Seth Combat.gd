extends "res://Scenes/Units/Unit_Scripts/Combat Unit.gd"

signal play_enemy_dodge_anim

func play_miss_sound():
	var random = int(rand_range(1,3))
	BattlefieldInfo.battle_sounds.get_node(str("Attack Miss ", random)).play(0)
	# Play Miss anim
	emit_signal("play_enemy_dodge_anim")

func shake_camera_crit():
	get_parent().get_parent().shake(0.5,50,30)

func shake_camera_regular():
	get_parent().get_parent().shake(0.2,50,30)