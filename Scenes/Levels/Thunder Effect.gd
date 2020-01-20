extends Sprite

# Random screen flashes

func _ready():
	randomize()
	$Interval.wait_time = (randi() % 40 + 15)
	$Interval.start(0)

# Lightning Interval
func _on_Interval_timeout():
	# Which sound?
	var sound_number = randi() % 2 + 1
	if get_parent().get_node("Combat Screen").current_combat_state == Combat_Screen.wait:
		if !BattlefieldInfo.victory && !BattlefieldInfo.game_over:
			$Anim.play(str("Flash ", sound_number))
	else:
		if !BattlefieldInfo.victory && !BattlefieldInfo.game_over:
			get_node(str("Thunder Sound ", sound_number))
	$Interval.wait_time = (randi() % 40 + 15)
