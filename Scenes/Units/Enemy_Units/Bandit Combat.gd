extends "res://Scenes/Units/Unit_Scripts/Combat Unit.gd"

signal play_player_dodge_anim

func play_attack_sound():
	var random = int(rand_range(1,4))
	BattlefieldInfo.battle_sounds.get_node(str("Attack ", random)).play(0)

func play_hit_sound():
	var random = int(rand_range(1,4))
	BattlefieldInfo.battle_sounds.get_node(str("Attack Hit ", random)).play(0)

func play_draw_sound():
	BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.draw_attack_sound()

func put_away_attack_sound():
	BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.put_away_attack_sound()

func play_miss_sound():
	var random = int(rand_range(1,3))
	BattlefieldInfo.battle_sounds.get_node(str("Attack Miss ", random)).play(0)
	# Play Enemy Miss anim
	emit_signal("play_player_dodge_anim")

func play_crit_sound():
	var random = int(rand_range(1,2))
	BattlefieldInfo.battle_sounds.get_node(str("Critical Hit ", random)).play(0)

func shake_camera_crit():
	get_parent().get_parent().shake(0.5,50,30)

func shake_camera_regular():
	get_parent().get_parent().shake(0.2,50,30)

func play_death_sound():
	BattlefieldInfo.battle_sounds.get_node("Death").play(0)

func death_anim_signal():
	emit_signal("death_anim_done")
