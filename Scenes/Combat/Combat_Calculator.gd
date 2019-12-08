extends Node

# Combat variables
const CRITICAL_BONUS = 3

# Double attack
var player_double_attack = false
var enemy_double_attack = false

# Double attack variables
var player_first_attack_hit = false
var player_first_attack_crit = false
var player_second_attack_hit = false
var player_second_attack_crit = false
var enemy_first_attack_hit = false
var enemy_first_attack_crit = false
var enemy_second_attack_hit = false
var enemy_second_attack_crit = false

# Animation stuff
var player_missed_first_attack = false
var enemy_missed_first_attack = false
var player_missed_second_attack = false
var enemy_missed_second_attack = false
var player_crit_first_attack = false
var player_crit_second_attack = false
var enemy_crit_first_attack = false
var enemy_crit_second_attack = false

# Counter attack enabled
var player_can_counter_attack = false
var enemy_can_counter_attack = false

# Weapon bonuses
var player_weapon_bonus = 0
var enemy_weapon_bonus = 0

# Accuracy Rate
var player_accuracy = 0
var enemy_accuracy = 0

# Critical strike rate
var player_critical_rate = 0
var enemy_critical_rate = 0

# Player Attack speed
var player_attack_speed = 0
var enemy_attack_speed = 0

# Damage preview for GUI
var player_damage = 0
var enemy_damage = 0

# Damage actual
var player_base_damage = 0
var player_base_def = 0
var enemy_base_damage = 0
var enemy_base_def = 0

# Actual damage for combat purposes
var player_first_actual_damage = 0
var enemy_first_actual_damage = 0
var player_second_actual_damage = 0
var enemy_second_actual_damage = 0

# Effective bonus
var player_effective_bonus = 1
var enemy_effective_bonus = 1

# Healing
var player_healing_total = 0

# Miss
var player_missed = false
var enemy_missed = false

func _ready():
	randomize()

func calculate_damage_and_previews():
	# Get Weapon bonuses
	get_weapon_bonus()

# Double Attack
func calculate_double_attack():
	# Check if speed doubles
	# Player
	player_attack_speed = get_attack_speed(BattlefieldInfo.combat_player_unit)
	enemy_attack_speed = get_attack_speed(BattlefieldInfo.combat_ai_unit)
	
	if player_attack_speed - enemy_attack_speed >= 4:
		player_double_attack = true
		enemy_double_attack = false
	elif enemy_attack_speed - player_attack_speed >= 4:
		player_double_attack = false
		enemy_double_attack = true
	else:
		player_double_attack = false
		enemy_double_attack = false
	
	print("FROM COMBAT CALC: ally double attack ", player_double_attack)
	print("FROM COMBAT CALC: enemy double attack ", enemy_double_attack)

# Hit Chance
func calculate_hit_chance():
	var c_player_accuracy = 0
	var c_player_avoidance = 0
	
	var c_ai_accuracy = 0
	var c_ai_avoidance = 0
	
	# Player
	c_player_accuracy = get_accuracy(BattlefieldInfo.combat_player_unit, player_weapon_bonus)
	c_player_avoidance = get_avoidance(BattlefieldInfo.combat_player_unit, player_attack_speed)
	
	# AI
	c_ai_accuracy = get_accuracy(BattlefieldInfo.combat_ai_unit, enemy_weapon_bonus)
	c_ai_avoidance = get_avoidance(BattlefieldInfo.combat_ai_unit, enemy_attack_speed)
	
	# Calculate Hit Chance
	player_accuracy = c_player_accuracy - c_ai_avoidance
	enemy_accuracy = c_ai_accuracy - c_player_avoidance
	
	if player_accuracy < 0:
		player_accuracy = 0
	
	if enemy_accuracy < 0:
		enemy_accuracy = 0
	
	if player_accuracy > 100:
		player_accuracy = 100
	
	if enemy_accuracy > 100:
		enemy_accuracy = 100

# Crit Chance
func calculate_crit_chance():
	player_critical_rate = (BattlefieldInfo.combat_player_unit.UnitStats.skill / 2) + BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.crit + BattlefieldInfo.combat_player_unit.UnitStats.bonus_crit - BattlefieldInfo.combat_ai_unit.UnitStats.luck
	enemy_critical_rate = (BattlefieldInfo.combat_ai_unit.UnitStats.skill / 2) + BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.crit + BattlefieldInfo.combat_ai_unit.UnitStats.bonus_crit - BattlefieldInfo.combat_player_unit.UnitStats.luck
	
	if player_critical_rate < 0:
		player_critical_rate = 0
	if enemy_critical_rate < 0:
		enemy_critical_rate = 0

# Damage Preview
func calculate_damage():
	# Reset stats first
	reset_stats()
	
	# Get Bonuses
	get_special_ability(BattlefieldInfo.combat_player_unit, BattlefieldInfo.combat_ai_unit)
	get_weapon_bonus()
	
	# Calculate double attack
	calculate_double_attack()
	
	# Calculate Crit
	calculate_crit_chance()
	
	# Calculate Hit Chance
	calculate_hit_chance()

	# Calculate Damage preview
	calculate_damage_amounts()
	
	# Check if units can counter
	check_if_units_can_counter()
	

# Process this to process combat
func process_player_combat():
	# Player
	var temp_player_damage = player_base_damage
	# Check Crit Chance
	if (crit_occurred(player_critical_rate)):
		print("FROM COMBAT CALC: PLAYER CRIT OCCURED FIRST")
		temp_player_damage *= 3
		player_first_actual_damage = temp_player_damage - enemy_base_def

		if player_first_actual_damage < 0:
			player_first_actual_damage = 0
		
		player_first_attack_crit = true
	else:
		# No Crit, check if unit hit or missed
		if (hit_occured(player_accuracy)):
			player_first_actual_damage = temp_player_damage - enemy_base_def
			player_first_attack_hit = true
			
			if player_first_actual_damage <= 0:
				player_first_actual_damage = 0
				print("FROM COMBAT CALC: NO DAMAGE DEALT FROM PLAYER FIRST")
		else:
			# Player missed
			print("FROM COMBAT CALC: PLAYER MISSED FIRST")
			player_first_actual_damage = 0
			player_missed_first_attack = true
			
	# Double attack
	if player_double_attack:
		temp_player_damage = player_base_damage
		# Check Crit Chance
		if (crit_occurred(player_critical_rate)):
			print("FROM COMBAT CALC: PLAYER CRIT OCCURED SECOND")
			temp_player_damage *= 3
			player_second_actual_damage = temp_player_damage - enemy_base_def
			player_second_attack_hit = true
			
			if player_second_actual_damage < 0:
				player_second_actual_damage = 0
			
			player_second_attack_crit = true
		else:
			# No Crit, check if unit hit or missed
			if (hit_occured(player_accuracy)):
				player_second_actual_damage = temp_player_damage - enemy_base_def
				player_second_attack_hit = true
				if player_second_actual_damage <= 0:
					player_second_actual_damage = 0
					print("FROM COMBAT CALC: NO DAMAGE DEALT FROM PLAYER SECOND")
			else:
				# Player missed
				print("FROM COMBAT CALC: PLAYER MISSED FIRST")
				player_second_actual_damage = 0
				player_missed_second_attack = true

func process_enemy_combat():
	# Check Crit Chance
	# First
	var temp_damage = enemy_base_damage
	if (crit_occurred(enemy_critical_rate)):
		print("FROM COMBAT CALC: ENEMY CRIT OCCURED FIRST")
		temp_damage *= 3
		enemy_first_actual_damage = temp_damage - player_base_def
		
		enemy_crit_first_attack = true
		
		if enemy_first_actual_damage < 0:
			enemy_first_actual_damage = 0
	else:
		# No Crit, check if unit hit or missed
		if (hit_occured(enemy_accuracy)):
			enemy_first_actual_damage = temp_damage - player_base_def
			enemy_first_attack_hit = true
			if enemy_first_actual_damage <= 0:
				enemy_first_actual_damage = 0
				print("FROM COMBAT CALC: NO DAMAGE DEALT FROM ENEMY FIRST")
		else:
			# Enemy Missed
			print("FROM COMBAT CALC: ENEMY MISSED FIRST")
			enemy_first_actual_damage = 0
			enemy_missed_first_attack = true
	
	# Second
	if enemy_double_attack:
		temp_damage = enemy_base_damage
		if (crit_occurred(enemy_critical_rate)):
			print("FROM COMBAT CALC: ENEMY CRIT OCCURED SECOND")
			temp_damage *= 3
			enemy_second_actual_damage = temp_damage - player_base_def
			
			enemy_second_attack_crit = true
			
			if enemy_second_actual_damage < 0:
				enemy_second_actual_damage = 0
		else:
			# No Crit, check if unit hit or missed
			if (hit_occured(enemy_accuracy)):
				enemy_second_actual_damage = temp_damage - player_base_def
				enemy_second_attack_hit = true
				if enemy_first_actual_damage <= 0:
					enemy_first_actual_damage = 0
					print("FROM COMBAT CALC: NO DAMAGE DEALT FROM ENEMY SECOND")
			else:
				# Enemy Missed
				print("FROM COMBAT CALC: ENEMY MISSED SECOND")
				enemy_second_actual_damage = 0
				enemy_missed_second_attack = true


####################
# Helper Functions #
####################
func calculate_damage_amounts():
	# Player
	if BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.item_class == Item.ITEM_CLASS.PHYSICAL:
		player_base_damage = BattlefieldInfo.combat_player_unit.UnitStats.strength
		enemy_base_def = BattlefieldInfo.combat_ai_unit.UnitStats.def
	elif BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.item_class == Item.ITEM_CLASS.MAGIC:
		player_base_damage = BattlefieldInfo.combat_player_unit.UnitStats.magic
		enemy_base_def = BattlefieldInfo.combat_ai_unit.UnitStats.res
	
	player_base_damage += ((BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.might + player_weapon_bonus) * player_effective_bonus)
	enemy_base_def += BattlefieldInfo.combat_ai_unit.UnitMovementStats.currentTile.defenseBonus
	
	# Set GUI
	player_damage = player_base_damage - enemy_base_def
	if player_damage < 0:
		player_damage = 0
	
	# Enemy
	if BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.item_class == Item.ITEM_CLASS.PHYSICAL:
		enemy_base_damage = BattlefieldInfo.combat_ai_unit.UnitStats.strength
		player_base_def = BattlefieldInfo.combat_player_unit.UnitStats.def
	elif BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.item_class == Item.ITEM_CLASS.MAGIC:
		enemy_base_damage = BattlefieldInfo.combat_ai_unit.UnitStats.magic
		player_base_def = BattlefieldInfo.combat_player_unit.UnitStats.res
	
	
	enemy_base_damage += ((BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.might + enemy_weapon_bonus) * enemy_effective_bonus)
	player_base_def += BattlefieldInfo.combat_player_unit.UnitMovementStats.currentTile.defenseBonus
	
	# Set GUI
	enemy_damage = enemy_base_damage - player_base_def
	if enemy_damage < 0:
		enemy_damage = 0
	

func get_attack_speed(unit):
	var item_weight_stat = clamp(unit.UnitInventory.current_item_equipped.weight - unit.UnitStats.consti, 0, 10000)
	return unit.UnitStats.speed - item_weight_stat

func get_accuracy(unit, weapon_bonus):
	return unit.UnitInventory.current_item_equipped.hit + (unit.UnitStats.skill * 2) + (unit.UnitStats.luck / 2) + (weapon_bonus * 15) + unit.UnitStats.bonus_hit

func get_avoidance(unit, attack_speed):
	return (attack_speed * 2) + unit.UnitStats.luck + unit.UnitMovementStats.currentTile.avoidanceBonus + unit.UnitStats.bonus_dodge

func get_special_ability(player_unit, ai_unit):
	player_effective_bonus = player_unit.UnitInventory.current_item_equipped.special_ability(player_unit, ai_unit)
	enemy_effective_bonus = ai_unit.UnitInventory.current_item_equipped.special_ability(ai_unit, player_unit)

func crit_occurred(crit_chance):
	if crit_chance >= 100:
		return true
	elif crit_chance <= 0:
		return false
		
	return int(rand_range(0, 100)) <= crit_chance

func hit_occured(accuracy_chance):
	if accuracy_chance >= 100:
		return true
	elif accuracy_chance <= 0:
		return false
	
	return int(rand_range(0,100)) <= accuracy_chance

func reset_stats():
	# Double attack
	player_double_attack = false
	enemy_double_attack = false
	
	# Weapon bonuses
	player_weapon_bonus = 0
	enemy_weapon_bonus = 0
	
	# Accuracy Rate
	player_accuracy = 0
	enemy_accuracy = 0
	
	# Critical strike rate
	player_critical_rate = 0
	enemy_critical_rate = 0
	
	# Damage preview for GUI
	player_damage = 0
	enemy_damage = 0
	
	# Actual damage for combat purposes
	player_first_actual_damage = 0
	enemy_first_actual_damage = 0
	player_second_actual_damage = 0
	enemy_second_actual_damage = 0
	
	# Effective bonus
	player_effective_bonus = 1
	enemy_effective_bonus = 1
	
	# Attack speed
	player_attack_speed = 0
	enemy_attack_speed = 0
	
	# Miss
	player_missed = false
	enemy_missed = false
	
	# Double attack variables
	player_first_attack_hit = false
	player_first_attack_crit = false
	player_second_attack_hit = false
	player_second_attack_crit = false
	enemy_first_attack_hit = false
	enemy_first_attack_crit = false
	enemy_second_attack_hit = false
	enemy_second_attack_crit = false
	
	# Animation stuff
	player_missed_first_attack = false
	enemy_missed_first_attack = false
	player_missed_second_attack = false
	enemy_missed_second_attack = false
	player_crit_first_attack = false
	player_crit_second_attack = false
	enemy_crit_first_attack = false
	enemy_crit_second_attack = false
	
	# Counter attack enabled
	player_can_counter_attack = false
	enemy_can_counter_attack = false
	
	# Damage
	player_base_damage = 0
	player_base_def = 0
	enemy_base_damage = 0
	enemy_base_def = 0

# Check if enemy/player can counter
func check_if_units_can_counter():
	# Reset Values
	player_can_counter_attack = false
	enemy_can_counter_attack = false

	# Check Range
	# Player
	if Calculators.get_distance_between_two_tiles(BattlefieldInfo.combat_player_unit.UnitMovementStats.currentTile, BattlefieldInfo.combat_ai_unit.UnitMovementStats.currentTile) <= BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.max_range:
		player_can_counter_attack = true
	if Calculators.get_distance_between_two_tiles(BattlefieldInfo.combat_player_unit.UnitMovementStats.currentTile, BattlefieldInfo.combat_ai_unit.UnitMovementStats.currentTile) <= BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.max_range:
		enemy_can_counter_attack = true
	
	# Is anyone unarmed?
	if BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.item_name == "Unarmed":
		player_can_counter_attack = false
	if BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.item_name == "Unarmed":
		enemy_can_counter_attack = false
	
	# Using a healing weapon?
	if BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_type == Item.WEAPON_TYPE.HEALING:
		player_can_counter_attack = false
	if BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_type == Item.WEAPON_TYPE.HEALING:
		enemy_can_counter_attack = false
	
func get_weapon_bonus():
	# Player
	if BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.strong_against == BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_type:
		player_weapon_bonus = 1
		enemy_weapon_bonus = -1
	elif BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.strong_against == BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_type:
		enemy_weapon_bonus = 1
		player_weapon_bonus = -1
	else:
		player_weapon_bonus = 0
		enemy_weapon_bonus = 0

func calculate_healing():
	player_healing_total = 0
	player_healing_total = BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.might + BattlefieldInfo.combat_player_unit.UnitStats.magic