extends "res://Scenes/Units/Unit_Scripts/Combat Unit.gd"

signal play_enemy_dodge_anim

func play_attack_sound():
	BattlefieldInfo.weapon_sounds.get_node("Bow Shoot").play(0)

func play_miss_sound():
	var random = int(rand_range(1,3))
	BattlefieldInfo.battle_sounds.get_node(str("Attack Miss ", random)).play(0)
	# Play Miss anim
	emit_signal("play_enemy_dodge_anim")

# This will only be called when Eirika dies for this animation
func game_over():
	pass