extends CanvasLayer

# Combat Process
func start_combat(): 
	# Process actual numbers
	Combat_Calculator.process_player_combat()
	Combat_Calculator.process_enemy_combat()
	
	# Place appropriate combat art
	place_combat_art()
	
	adjust_gui_text_and_hp_box()
	
	# Attack whoever is first
	var ally = true # placeholder
	process_first_attack(ally)
	
	# If not dead and able to counter attack
	var enemy = true # placeholder
	process_first_attack(enemy)

# Get the 
func place_combat_art():
	pass

func adjust_gui_text_and_hp_box():
	pass

func process_first_attack(unit):
	pass
	# Check if miss/crit/hit
	# play appropariate animations
	# play appropriate sound effects
	# update damage
	# update world
	# return to map

func clean_up():
	pass