extends Node2D

signal play_enemy_dodge_anim

func play_attack_sound():
	var random = randi() % 3 + 1
	BattlefieldInfo.battle_sounds.get_node(str("Attack ", random)).play(0)

func play_hit_sound():
	var random = randi() % 3 + 1
	BattlefieldInfo.battle_sounds.get_node(str("Attack Hit ", random)).play(0)

func play_draw_sound():
	BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.draw_attack_sound()

func put_away_attack_sound():
	BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.put_away_attack_sound()

func play_miss_sound():
	var random = randi() % 2 + 1
	BattlefieldInfo.battle_sounds.get_node(str("Attack Miss ", random)).play(0)
	# Play Miss anim
	emit_signal("play_enemy_dodge_anim")

func play_crit_sound():
	var random = randi() % 1 + 1
	BattlefieldInfo.battle_sounds.get_node(str("Critical Hit ", random)).play(0)

func shake_camera_crit():
	get_parent().get_parent().shake(0.5,50,30)

func shake_camera_regular():
	get_parent().get_parent().shake(0.2,50,30)