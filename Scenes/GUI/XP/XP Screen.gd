extends Control

# Calculation Info Formulas
#
# Class power: 1 for Journeyman (1), Recruit (1), Pupil (1), Civilian, Pontifex and Entombed, 2 for Cleric, 
# Soldier, Troubadour, Manakete (M), Manakete (F), Thief, Priest and Dancer, 5 for Demon King, 3 for everything else.
#
# Class bonus A: 0 for non-promoted classes, 20 for promoted classes.
# Class bonus B: 0 for non-promoted classes, 40 for Assassins, Rogues, Bishops and Valkyries, 60 for all other promoted classes.
#
# Mode coefficient: Initially treat this value as being 1. If Experience from defeating (base) 
# is calculated as 0 or negative, this value becomes 2 instead. For all other cases it remains 1.
# 
# Boss bonus: 40 if enemy is a boss, 0 if not.
# Thief bonus: 20 if enemy is a Thief, Rogue or Assassin, 0 if not.
#
# Note: Experience from defeating enemy is rounded up if Mode coefficient is 2.

# Constants
const NO_DAMAGE_XP = 1
const BASE_XP = 31

# Mode Coefficient
var mode_coefficient = 1

# XP
var damage_xp = 0
var defeat_base_enemy_xp = 0
var final_xp_earned = 0

# Level up
var has_unit_leveled_up = false

# State
enum {damage, no_damage, death, progress, wait}
var current_state = wait

# Speed
const SPEED = 30

# Signal done
signal done_adding_xp

func _process(delta):
	match current_state:
		damage:
			final_xp_earned = damage_xp
			current_state = progress
			$xp_gain.play(0)
		no_damage:
			current_state = progress
			$xp_gain.play(0)
		death:
			current_state = progress
			$xp_gain.play(0)
		progress:
			move_xp_bar(delta)
		wait:
			pass

func move_xp_bar(delta):
	# Add XP
	var value_to_change = (SPEED * delta)
	
	# Change XP Value
	BattlefieldInfo.combat_player_unit.UnitStats.current_xp += value_to_change
	final_xp_earned -= value_to_change
	
	# Update box
	set_gui_box()
	
	# Did we pass 100?
	if BattlefieldInfo.combat_player_unit.UnitStats.current_xp >= Unit_Stats.NEXT_LEVEL_XP:
		has_unit_leveled_up = true
		BattlefieldInfo.combat_player_unit.UnitStats.current_xp = 0
	
	# Did we finish adding xp?
	if final_xp_earned <= 0:
		$xp_gain.stop()
		# Round off values to prevent errors
		final_xp_earned = 0
		BattlefieldInfo.combat_player_unit.UnitStats.current_xp = int(BattlefieldInfo.combat_player_unit.UnitStats.current_xp)
		
		# If unit leveled up
		if has_unit_leveled_up:
			current_state = wait
			
			# Lower volume of the music
			if BattlefieldInfo.turn_manager.turn == Turn_Manager.ENEMY_TURN:
				BattlefieldInfo.music_player.get_node("Enemy Combat").volume_db = -12
			else:
				BattlefieldInfo.music_player.get_node("Ally Combat").volume_db = -12
			
			get_parent().get_node("Level Up Screen").start()
		else:
			current_state = wait
			# Back to battlefield
			$Return.start(0)

# TO DO LIST
# Determine if death or regular
# Calculate XP gained
# Let box finish filling up
# Check if leveled up - Go there
# Remove this and head back once done

# Helper Functions
func start():
	# Reset stats
	damage_xp = 0
	final_xp_earned = 0
	defeat_base_enemy_xp = 0
	mode_coefficient = 1
	has_unit_leveled_up = false
	
	# UI
	set_gui_box()
	visible = true
	
	# Numbers
	calculate_damage_xp()
	current_state = damage

func start_no_damage_or_miss():
	damage_xp = 0
	final_xp_earned = 1
	defeat_base_enemy_xp = 0
	mode_coefficient = 1
	has_unit_leveled_up = false
	
	# UI
	set_gui_box()
	visible = true
	
	current_state = no_damage

func start_death():
	# Reset stats
	damage_xp = 0
	final_xp_earned = 0
	defeat_base_enemy_xp = 0
	mode_coefficient = 1
	has_unit_leveled_up = false
	
	# UI
	set_gui_box()
	visible = true
	
	# Number
	calculate_damage_xp()
	calculate_base_defeat()
	calculate_total_defeat()
	
	current_state = death
	
# Set Box
func set_gui_box():
	# Box
	$"xp_ui/xp_full_bar".region_rect = Rect2(0, 0, 488 * (float(BattlefieldInfo.combat_player_unit.UnitStats.current_xp / Unit_Stats.NEXT_LEVEL_XP)), 35)
	
	# Text
	$"xp_ui/xp_value".text = str(int(BattlefieldInfo.combat_player_unit.UnitStats.current_xp))

# Damage XP
func calculate_damage_xp():
	# Formula = [31 + (enemy’s Level + enemy’s Class bonus A) – (Level + Class bonus A)] / Class power
	damage_xp = (BASE_XP + (BattlefieldInfo.combat_ai_unit.UnitStats.level + BattlefieldInfo.combat_ai_unit.UnitStats.class_bonus_a) - \
	(BattlefieldInfo.combat_player_unit.UnitStats.level + BattlefieldInfo.combat_player_unit.UnitStats.class_bonus_a)) / BattlefieldInfo.combat_player_unit.UnitStats.class_power
	
	if damage_xp <= 0:
		damage_xp = 1

# Death
func calculate_base_defeat():
	defeat_base_enemy_xp = ((BattlefieldInfo.combat_ai_unit.UnitStats.level * BattlefieldInfo.combat_ai_unit.UnitStats.class_power) + BattlefieldInfo.combat_ai_unit.UnitStats.class_bonus_b) - \
	(((BattlefieldInfo.combat_player_unit.UnitStats.level * BattlefieldInfo.combat_player_unit.UnitStats.class_power) + BattlefieldInfo.combat_player_unit.UnitStats.class_bonus_b) / mode_coefficient)
	
	# Set new if < 0
	if defeat_base_enemy_xp <= 0:
		mode_coefficient = 2
		defeat_base_enemy_xp = ((BattlefieldInfo.combat_ai_unit.UnitStats.level * BattlefieldInfo.combat_ai_unit.UnitStats.class_power) + BattlefieldInfo.combat_ai_unit.UnitStats.class_bonus_b) - \
		(((BattlefieldInfo.combat_player_unit.UnitStats.level * BattlefieldInfo.combat_player_unit.UnitStats.class_power) + BattlefieldInfo.combat_player_unit.UnitStats.class_bonus_b) / mode_coefficient) 

# Death Total
func calculate_total_defeat():
	final_xp_earned = damage_xp + (defeat_base_enemy_xp + 20 + BattlefieldInfo.combat_ai_unit.UnitStats.boss_bonus + BattlefieldInfo.combat_ai_unit.UnitStats.thief_bonus)
	
	if final_xp_earned <= 0:
		final_xp_earned = 1

func _on_Return_timeout():
	current_state = wait
	emit_signal("done_adding_xp")