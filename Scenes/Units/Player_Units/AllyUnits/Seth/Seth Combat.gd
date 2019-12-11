extends "res://Scenes/Units/Unit_Scripts/Combat Unit.gd"

signal play_enemy_dodge_anim

func play_miss_sound():
	var random = int(rand_range(1,3))
	BattlefieldInfo.battle_sounds.get_node(str("Attack Miss ", random)).play(0)
	# Play Miss anim
	emit_signal("play_enemy_dodge_anim")

func turn_off():
	pass
#	$"Lance Sprite Crit".visible = false
#	$"Lance Sprite Regular".visible = false
#	$"Seth Sword Regular".visible = false
