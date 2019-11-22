extends Node2D

func play_draw_sound():
	BattlefieldInfo.weapon_sounds.get_node("Draw Weapon").play(0)

func play_put_away():
	BattlefieldInfo.weapon_sounds.get_node("Put Away Weapon").play(0)

func play_attack_sound():
	var random = randi() % 3 + 1
	BattlefieldInfo.battle_sounds.get_node(str("Attack ", random)).play(0)

func play_hit_sound():
	var random = randi() % 3 + 1
	BattlefieldInfo.battle_sounds.get_node(str("Attack Hit ", random)).play(0)

func _on_anim_animation_finished(anim_name):
	get_parent().get_node("Bandit Combat/anim").play("regular")
