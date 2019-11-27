extends Node2D

signal play_player_dodge_anim

func play_attack_sound():
	var random = randi() % 3 + 1
	BattlefieldInfo.battle_sounds.get_node(str("Attack ", random)).play(0)

func play_hit_sound():
	var random = randi() % 3 + 1
	BattlefieldInfo.battle_sounds.get_node(str("Attack Hit ", random)).play(0)

func play_draw_sound():
	BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.draw_attack_sound()

func put_away_attack_sound():
	BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.put_away_attack_sound()

func play_miss_sound():
	var random = randi() % 2 + 1
	BattlefieldInfo.battle_sounds.get_node(str("Attack Miss ", random)).play(0)
	# Play Enemy Miss anim
	emit_signal("play_player_dodge_anim")

func play_crit_sound():
	var random = randi() % + 1
	BattlefieldInfo.battle_sounds.get_node(str("Critical Hit ", random)).play(0)