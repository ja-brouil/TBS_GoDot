extends Control

class_name Combat_Screen

# Nodes
var player_node_name
var enemy_node_name

# Backgrounds
var plain = preload("res://assets/UI/combatUI/Plains.png")
var forest = preload("res://assets/UI/combatUI/Forest.png")
var fortress = preload("res://assets/UI/combatUI/Fortress.png")
var mountain = preload("res://assets/UI/combatUI/Mountain.png")
var river = preload("res://assets/UI/combatUI/River.png")
var sea = preload("res://assets/UI/combatUI/Sea.png")
var village = preload("res://assets/UI/combatUI/Village.png")

# Speed for HP decrease
const SPEED = 20

# Music Playback
var ally_song_location = 0
var enemy_song_location = 0

# Update hp + variables needed
enum {player_first_turn, player_hp_first_update, enemy_first_turn, enemy_hp_first_update, player_second_turn, 
player_hp_second_update, enemy_second_turn, enemy_hp_second_update, player_death, enemy_death, player_healing, 
player_healing_adjust, enemy_healing, enemy_healing_adjust, player_death_quote, enemy_death_quote, wait}
var current_combat_state = wait
var previous_combat_state = wait
var next_combat_state
var player_hp_destination = 0
var enemy_hp_destination = 0

# Messaging system during the battle
enum {before_fight, ally_death, after_fight, no_process}
var messaging_state = no_process

# Healing Flip
var flip_enemy = false

# Broken item
var broke_item = false

# Placeholders
var ally_placeholder
var enemy_placeholder

# Cinematic Branch
var cinematic_branch = false
signal combat_screen_done

# Game Over
var game_over = false

# Show highlight positions
var highlight_positions = false

# Ready
func _ready():
	$"Combat Control/Combat UI/XP Screen".connect("done_adding_xp", self, "back_to_battlefield")
	$"Combat Control/Combat UI/Level Up Screen".connect("done_leveling_up", self, "back_to_battlefield")
	get_parent().get_parent().get_node("Message System").connect("no_more_text", self, "process_after_text") # Change this later to accomodate boss units
	
	BattlefieldInfo.combat_screen = self
	set_process(true)

# State update
func _process(delta):
	# Player Turn
	if BattlefieldInfo.turn_manager.turn == Turn_Manager.PLAYER_TURN:
		match current_combat_state:
			player_first_turn:
				player_attack()
			player_hp_first_update:
				# update GUI Box
				adjust_enemy_hp_box_over_time(delta)
				# Did we pass the destination HP? Else, just continue
				if BattlefieldInfo.combat_ai_unit.UnitStats.current_health <= enemy_hp_destination:
					BattlefieldInfo.combat_ai_unit.UnitStats.current_health = enemy_hp_destination
					set_enemy_box()
					# Is the unit dead?
					if BattlefieldInfo.combat_ai_unit.UnitStats.current_health <= 0:
						current_combat_state = enemy_death
						return
					# Can the unit counter attack?
					if Combat_Calculator.enemy_can_counter_attack:
						# Set next state to enemy first attack
						current_combat_state = enemy_first_turn
						previous_combat_state = enemy_first_turn
					# Can the player hit twice and the enemy CANNOT counter attack
					elif !Combat_Calculator.enemy_can_counter_attack && Combat_Calculator.player_double_attack:
						current_combat_state = player_second_turn
						previous_combat_state = player_second_turn
					# Player cannot double and the enemy cannot counter then we exit
					else:
						process_xp()
			enemy_first_turn:
				enemy_attack()
			enemy_hp_first_update:
				# update GUI Box
				adjust_player_hp_box_over_time(delta)
				# Did we pass the destination HP? Else, just continue
				if BattlefieldInfo.combat_player_unit.UnitStats.current_health <= player_hp_destination:
					BattlefieldInfo.combat_player_unit.UnitStats.current_health = player_hp_destination
					set_player_box()
					# Is the unit dead?
					if BattlefieldInfo.combat_player_unit.UnitStats.current_health <= 0:
						current_combat_state = player_death
						return
					# Can we attack twice as a player?
					if Combat_Calculator.player_double_attack:
						# Set next state to enemy first attack
						current_combat_state = player_second_turn
						previous_combat_state = player_second_turn
					# can we NOT double as the player but the enemy can
					elif Combat_Calculator.enemy_double_attack && !Combat_Calculator.player_double_attack:
						current_combat_state = enemy_second_turn
						previous_combat_state = enemy_second_turn
					else:
						process_xp()
			player_second_turn:
				player_attack()
			player_hp_second_update:
				# update GUI Box
				adjust_enemy_hp_box_over_time(delta)
				# Did we pass the destination HP? Else, just continue
				if BattlefieldInfo.combat_ai_unit.UnitStats.current_health <= enemy_hp_destination:
					BattlefieldInfo.combat_ai_unit.UnitStats.current_health = enemy_hp_destination
					set_enemy_box()
					# Is the unit dead?
					if BattlefieldInfo.combat_ai_unit.UnitStats.current_health <= 0:
						current_combat_state = enemy_death
						return
					# Can the unit counter attack? and has a double attack
					if Combat_Calculator.enemy_can_counter_attack && Combat_Calculator.enemy_double_attack:
						# Set next state to enemy first attack
						current_combat_state = enemy_second_turn
						previous_combat_state = enemy_second_turn
					# Player has attacked twice and enemy cannot double so we are done
					else:
						process_xp()
			enemy_second_turn:
				enemy_attack()
			enemy_hp_second_update:
				# update GUI Box
				adjust_player_hp_box_over_time(delta)
				# Did we pass the destination HP? Else, just continue
				if BattlefieldInfo.combat_player_unit.UnitStats.current_health <= player_hp_destination:
					BattlefieldInfo.combat_player_unit.UnitStats.current_health = player_hp_destination
					set_player_box()
					# Is the unit dead?
					if BattlefieldInfo.combat_player_unit.UnitStats.current_health <= 0:
						current_combat_state = player_death
						return
					else:
						process_xp()
			player_death:
				process_ally_death()
				return
			enemy_death:
				process_enemy_death()
				return
			player_healing:
				# Play healing anim
				#enemy_node_name.flip_h = true
				#flip_enemy = true
				player_healing_anim()
			player_healing_adjust:
				# Update
				adjust_healing_player(delta)
				
				# Did we pass our destination hp?
				if BattlefieldInfo.combat_ai_unit.UnitStats.current_health >= enemy_hp_destination:
					BattlefieldInfo.combat_ai_unit.UnitStats.current_health = enemy_hp_destination
					set_enemy_box()
					process_heal_xp()
					current_combat_state = wait
			wait:
				pass
	elif BattlefieldInfo.turn_manager.turn == Turn_Manager.ENEMY_COMBAT_TURN:
			match current_combat_state:
				enemy_first_turn:
					enemy_attack()
				enemy_hp_first_update:
					# update GUI Box
					adjust_player_hp_box_over_time(delta)
					# Did we pass the destination HP? Else, just continue
					if BattlefieldInfo.combat_player_unit.UnitStats.current_health <= player_hp_destination:
						BattlefieldInfo.combat_player_unit.UnitStats.current_health = player_hp_destination
						set_player_box()
						# Is the unit dead?
						if BattlefieldInfo.combat_player_unit.UnitStats.current_health <= 0:
							current_combat_state = player_death
							return
						# Can we attack as a player?
						if Combat_Calculator.player_can_counter_attack:
							# Set next state to player first attack
							current_combat_state = player_first_turn
							previous_combat_state = player_first_turn
						# can we NOT counter as a player AND the enemy can double attack
						elif !Combat_Calculator.player_can_counter_attack && Combat_Calculator.enemy_double_attack:
							current_combat_state = enemy_second_turn
							previous_combat_state = enemy_second_turn
						else:
							process_xp()
				player_first_turn:
					player_attack()
				player_hp_first_update:
					# update GUI Box
					adjust_enemy_hp_box_over_time(delta)
					# Did we pass the destination HP? Else, just continue
					if BattlefieldInfo.combat_ai_unit.UnitStats.current_health <= enemy_hp_destination:
						BattlefieldInfo.combat_ai_unit.UnitStats.current_health = enemy_hp_destination
						set_enemy_box()
						# Is the unit dead?
						if BattlefieldInfo.combat_ai_unit.UnitStats.current_health <= 0:
							current_combat_state = enemy_death
							return
						# Can the unit counter attack and has a double attack?
						if Combat_Calculator.enemy_can_counter_attack && Combat_Calculator.enemy_double_attack:
							# Set next state to enemy second attack
							current_combat_state = enemy_second_turn
							previous_combat_state = enemy_second_turn
						# Enemy CANNOT double attack but we can
						elif !Combat_Calculator.enemy_double_attack && Combat_Calculator.player_can_counter_attack && Combat_Calculator.player_double_attack:
							current_combat_state = player_second_turn
							previous_combat_state = player_second_turn
						else:
							process_xp()
				enemy_second_turn:
					enemy_attack()
				enemy_hp_second_update:
					# update GUI Box
					adjust_player_hp_box_over_time(delta)
					# Did we pass the destination HP? Else, just continue
					if BattlefieldInfo.combat_player_unit.UnitStats.current_health <= player_hp_destination:
						BattlefieldInfo.combat_player_unit.UnitStats.current_health = player_hp_destination
						set_player_box()
						# Is the unit dead?
						if BattlefieldInfo.combat_player_unit.UnitStats.current_health <= 0:
							current_combat_state = player_death
							return
						# Can we attack as a player AND have a double attack?
						if Combat_Calculator.player_can_counter_attack && Combat_Calculator.player_double_attack:
							# Set next state to player first attack
							current_combat_state = player_second_turn
							previous_combat_state = player_second_turn
						else:
							# No one can attack anymore so we are done
							process_xp()
				player_second_turn:
					player_attack()
				player_hp_second_update:
					# update GUI Box
					adjust_enemy_hp_box_over_time(delta)
					# Did we pass the destination HP? Else, just continue
					if BattlefieldInfo.combat_ai_unit.UnitStats.current_health <= enemy_hp_destination:
						BattlefieldInfo.combat_ai_unit.UnitStats.current_health = enemy_hp_destination
						set_enemy_box()
						# Is the unit dead?
						if BattlefieldInfo.combat_ai_unit.UnitStats.current_health == 0:
							current_combat_state = enemy_death
							return
						# No more combat here
						process_xp()
				enemy_death:
					process_enemy_death()
				player_death:
					process_ally_death()
				enemy_healing:
					pass
				enemy_healing_adjust:
					pass
				wait:
					# Do not process if we are here
					pass
				

# Combat Process
func start_combat(current_combat_state): 
	set_process(true)
	
	# Process actual numbers
	Combat_Calculator.process_player_combat()
	Combat_Calculator.process_enemy_combat()
	
	# Set destination to 0
	player_hp_destination = 0
	enemy_hp_destination = 0
	
	# Turn off units and background
	BattlefieldInfo.current_level.get_node("Anim").play("Fade") #modulate = Color(1,1,1,0.5)
	
	# Set player and unit to done
	if BattlefieldInfo.turn_manager.turn == Turn_Manager.ENEMY_COMBAT_TURN:
		BattlefieldInfo.combat_ai_unit.UnitActionStatus.set_current_action(Unit_Action_Status.DONE)
	
	# Set the visible back
	modulate = Color(1,1,1,1)
	
	# Turn off the highlight squares and set back to false for the value
	for enemy in BattlefieldInfo.enemy_units.values():
			BattlefieldInfo.movement_calculator.turn_off_purple(enemy, BattlefieldInfo.grid)
	# Save the value so that we can turn it back on later
	if BattlefieldInfo.cursor.enemy_position_state:
		highlight_positions = true
	BattlefieldInfo.cursor.enemy_position_state = false
	
		# Turn off Units
	for ally_unit in BattlefieldInfo.ally_units.values():
		ally_unit.visible = false

	for enemy_unit in BattlefieldInfo.enemy_units.values():
		enemy_unit.visible = false
	
	# Play Transition
	$"Combat Trans".play_transition_forward()
	yield($"Combat Trans", "transition_done")
	
	# Set to 0.5 Modulate
	BattlefieldInfo.current_level.modulate = Color(1,1,1,0.5)
	
	# Place appropriate combat art
	place_combat_art()
	
	# Adjust GUI Box
	adjust_gui_text_and_hp_box()
	
	# Set Background
	set_background(BattlefieldInfo.combat_player_unit.UnitMovementStats.currentTile.tileName)
	
	# Turn on
	turn_on()
	
	# Play fade
	$"Combat Trans".play_fade()
	yield($"Combat Trans", "fade_done")
	
	# Set Next
	next_combat_state = current_combat_state
	
	# Check if there is before battle text here
	if BattlefieldInfo.combat_ai_unit.before_battle_sentence != null:
		yield(get_tree().create_timer(0.5), "timeout")
		BattlefieldInfo.message_system.set_position(Messaging_System.BOTTOM)
		BattlefieldInfo.message_system.start(BattlefieldInfo.combat_ai_unit.before_battle_sentence)
		messaging_state = before_fight
	else:
		$Pause.start(0)

# Get the appropriate art
func place_combat_art():
	# Player
	player_node_name = BattlefieldInfo.combat_player_unit.combat_node.instance()
	player_node_name.position = $"Ally Unit".position
	
	# Placeholders
	ally_placeholder = BattlefieldInfo.combat_player_unit.combat_node.instance()
	ally_placeholder.position = $"Ally Unit".position
	var anim_name = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
	ally_placeholder.get_node(anim_name).visible = true
	ally_placeholder.z_index += 1
	add_child(ally_placeholder)
	
	# Player Animation Signals
	player_node_name.connect("play_enemy_dodge_anim", self, "play_enemy_miss_anim")
	player_node_name.connect("death_anim_done", self, "on_ally_death_complete")
	player_node_name.get_node("anim").connect("animation_finished", self, "update_hp_number")
	add_child(player_node_name)
	
	# Enemy
	enemy_node_name = BattlefieldInfo.combat_ai_unit.combat_node.instance()
	enemy_node_name.position = $"Enemy Unit".position
	
	# Placeholders
	enemy_placeholder = BattlefieldInfo.combat_ai_unit.combat_node.instance()
	enemy_placeholder.position = $"Enemy Unit".position
	var anim_name2 = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
	enemy_placeholder.get_node(anim_name2).visible = true
	enemy_placeholder.z_index += 1
	add_child(enemy_placeholder)
	
	# Enemy Miss signal
	if !BattlefieldInfo.combat_ai_unit.UnitMovementStats.is_ally:
		enemy_node_name.connect("play_player_dodge_anim", self, "play_player_miss_anim")
	enemy_node_name.connect("death_anim_done", self, "on_enemy_death_complete")
	enemy_node_name.get_node("anim").connect("animation_finished", self, "update_hp_number")
	add_child(enemy_node_name)

# Set appropriate text
func adjust_gui_text_and_hp_box():
	# Player
	$"Combat Control/Combat UI/Player/Player Name".text = BattlefieldInfo.combat_player_unit.UnitStats.name
	$"Combat Control/Combat UI/Player/Player HP Number".text = str(int(BattlefieldInfo.combat_player_unit.UnitStats.current_health))
	$"Combat Control/Combat UI/Player/Player Hit".text = str(Combat_Calculator.player_accuracy)
	$"Combat Control/Combat UI/Player/Player Dmg".text = str(Combat_Calculator.player_damage)
	$"Combat Control/Combat UI/Player/Player Crt".text = str(Combat_Calculator.player_critical_rate)
	$"Combat Control/Combat UI/Player/Player Weapon Name".text = BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.item_name
	$"Combat Control/Combat UI/Player/Player Item Icon".texture = BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.icon
	
	# Set player rect %
	$"Combat Control/Combat UI/Player/Player Full HP".region_rect = Rect2(0, 0, 273 * \
	(float(BattlefieldInfo.combat_player_unit.UnitStats.current_health) / float(BattlefieldInfo.combat_player_unit.UnitStats.max_health)), \
	37)
	
	# Enemy
	$"Combat Control/Combat UI/Enemy/Enemy Name".text = BattlefieldInfo.combat_ai_unit.UnitStats.name
	$"Combat Control/Combat UI/Enemy/Enemy HP Number".text = str(int(BattlefieldInfo.combat_ai_unit.UnitStats.current_health))
	$"Combat Control/Combat UI/Enemy/Enemy Hit".text = str(Combat_Calculator.enemy_accuracy)
	$"Combat Control/Combat UI/Enemy/Enemy Dmg".text = str(Combat_Calculator.enemy_damage)
	$"Combat Control/Combat UI/Enemy/Enemy Crt".text = str(Combat_Calculator.enemy_critical_rate)
	$"Combat Control/Combat UI/Enemy/Enemy Weapon Name".text = BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.item_name
	$"Combat Control/Combat UI/Enemy/Enemy Item Icon".texture = BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.icon
	
	# Set enemy rect %
	$"Combat Control/Combat UI/Enemy/Enemy Full HP".region_rect = Rect2(0, 0, 273 * \
	(float(BattlefieldInfo.combat_ai_unit.UnitStats.current_health) / float(BattlefieldInfo.combat_ai_unit.UnitStats.max_health)), \
	37)
	
	# Set Arrows
	# Weapon Bonus
	if current_combat_state != player_healing:
		if Combat_Calculator.player_weapon_bonus == 1:
			$"Combat Control/Combat UI/Player/Player Up Arrow Combat".visible = true
		elif Combat_Calculator.player_weapon_bonus == -1:
			$"Combat Control/Combat UI/Player/Player Down Arrow Combat".visible = true
		
			# Weapon Bonus
		if Combat_Calculator.enemy_weapon_bonus == 1:
			$"Combat Control/Combat UI/Enemy/Enemy Up Arrow Combat".visible = true
		elif Combat_Calculator.enemy_weapon_bonus == -1:
			$"Combat Control/Combat UI/Enemy/Enemy Down Arrow Combat".visible = true

# Adjust player hp over time
func adjust_player_hp_box_over_time(delta):
	# Adjust HP
	BattlefieldInfo.combat_player_unit.UnitStats.current_health -= (SPEED * delta)
	
	# Set player rect %
	$"Combat Control/Combat UI/Player/Player Full HP".region_rect = Rect2(0, 0, 273 * \
	(float(BattlefieldInfo.combat_player_unit.UnitStats.current_health) / float(BattlefieldInfo.combat_player_unit.UnitStats.max_health)), \
	37)
	
	# Adjust HP Text
	var temp = int(BattlefieldInfo.combat_player_unit.UnitStats.current_health)
	$"Combat Control/Combat UI/Player/Player HP Number".text = str(temp)

func set_player_box():
	# Set player rect %
	$"Combat Control/Combat UI/Player/Player Full HP".region_rect = Rect2(0, 0, 273 * \
	(float(BattlefieldInfo.combat_player_unit.UnitStats.current_health) / float(BattlefieldInfo.combat_player_unit.UnitStats.max_health)), \
	37)
	
	# Adjust HP Text
	var temp = int(BattlefieldInfo.combat_player_unit.UnitStats.current_health)
	$"Combat Control/Combat UI/Player/Player HP Number".text = str(temp)

func adjust_healing_player(delta):
	# Adjust HP
	BattlefieldInfo.combat_ai_unit.UnitStats.current_health += (SPEED * delta)
	
	# Set enemy rect %
	$"Combat Control/Combat UI/Enemy/Enemy Full HP".region_rect = Rect2(0, 0, 273 * \
	(float(BattlefieldInfo.combat_ai_unit.UnitStats.current_health) / float(BattlefieldInfo.combat_ai_unit.UnitStats.max_health)), \
	37)
	
	# Adjust HP Text
	var temp = int(BattlefieldInfo.combat_ai_unit.UnitStats.current_health)
	$"Combat Control/Combat UI/Enemy/Enemy HP Number".text = str(temp)

func player_healing_anim():
	current_combat_state = wait
	
	player_node_name.get_node("anim").play("staff regular")
	ally_placeholder.visible = false
	
	# Subtract durability from the weapon
	BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.uses -= 1
	# Check if the weapon broke
	if BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.uses <= 0:
		broke_item = true

# Adjust enemy hp over time
func adjust_enemy_hp_box_over_time(delta):
	# Adjust HP
	BattlefieldInfo.combat_ai_unit.UnitStats.current_health -= (SPEED * delta)
	
	# Set enemy rect %
	$"Combat Control/Combat UI/Enemy/Enemy Full HP".region_rect = Rect2(0, 0, 273 * \
	(float(BattlefieldInfo.combat_ai_unit.UnitStats.current_health) / float(BattlefieldInfo.combat_ai_unit.UnitStats.max_health)), \
	37)
	
	# Adjust HP Text
	var temp = int(BattlefieldInfo.combat_ai_unit.UnitStats.current_health)
	$"Combat Control/Combat UI/Enemy/Enemy HP Number".text = str(temp)

func set_enemy_box():
	# Set enemy rect %
	$"Combat Control/Combat UI/Enemy/Enemy Full HP".region_rect = Rect2(0, 0, 273 * \
	(float(BattlefieldInfo.combat_ai_unit.UnitStats.current_health) / float(BattlefieldInfo.combat_ai_unit.UnitStats.max_health)), \
	37)
	
	# Adjust HP Text
	var temp = int(BattlefieldInfo.combat_ai_unit.UnitStats.current_health)
	$"Combat Control/Combat UI/Enemy/Enemy HP Number".text = str(temp)

# Set Appropriate background
func set_background(tilename):
	match tilename:
		"Plain":
			$"Combat Control/Background".texture = plain
		"Forest":
			$"Combat Control/Background".texture = forest
		"Fortress":
			$"Combat Control/Background".texture = fortress
		"Mountain" || "Hill":
			$"Combat Control/Background".texture = mountain
		"River":
			$"Combat Control/Background".texture = river
		"Sea":
			$"Combat Control/Background".texture = sea
		"Village":
			$"Combat Control/Background".texture = village
		_: # Fall back -> add more later
			$"Combat Control/Background".texture = plain

func player_attack():
	# Wait
	current_combat_state = wait
	
	# Did the ally crit?
	if previous_combat_state == player_first_turn:
		if Combat_Calculator.player_first_attack_crit:
			var anim_name = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " crit")
			player_node_name.get_node("anim").play(anim_name)
		elif Combat_Calculator.player_first_attack_hit:
			# Play Regular
			var anim_name = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
			player_node_name.get_node("anim").play(anim_name)
		else:
			# Player missed
			var anim_name = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " miss")
			player_node_name.get_node("anim").play(anim_name)
	
	if previous_combat_state == player_second_turn:
		if Combat_Calculator.player_second_attack_crit:
			var anim_name = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " crit")
			player_node_name.get_node("anim").play(anim_name)
		elif Combat_Calculator.player_second_attack_hit:
			# Play Regular
			var anim_name = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
			player_node_name.get_node("anim").play(anim_name)
		else:
			# Player missed
			var anim_name = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " miss")
			player_node_name.get_node("anim").play(anim_name)
	
	# Turn player off
	var anim_name_off = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
	ally_placeholder.get_node(anim_name_off).visible = false
	
	# Subtract durability from the weapon
	BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.uses -= 1
	# Check if the weapon broke
	if BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.uses <= 0:
		broke_item = true
		Combat_Calculator.player_can_counter_attack = false
		Combat_Calculator.player_double_attack = false

func enemy_attack():
	# Wait
	current_combat_state = wait
	
	# Did the enemy crit?
	if previous_combat_state == enemy_first_turn:
		if Combat_Calculator.enemy_crit_first_attack:
			var anim_name = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " crit")
			enemy_node_name.get_node("anim").play(anim_name)
		elif Combat_Calculator.enemy_first_attack_hit:
			# Play Regular
			var anim_name = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
			enemy_node_name.get_node("anim").play(anim_name)
		else:
			# Enemy Missed
			var anim_name = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " miss")
			enemy_node_name.get_node("anim").play(anim_name)
		
		# Did the enemy crit?
	if previous_combat_state == enemy_second_turn:
		if Combat_Calculator.enemy_crit_second_attack:
			var anim_name = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " crit")
			enemy_node_name.get_node("anim").play(anim_name)
		elif Combat_Calculator.enemy_second_attack_hit:
			# Play Regular
			var anim_name = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
			enemy_node_name.get_node("anim").play(anim_name)
		else:
			# Enemy Missed
			var anim_name = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " miss")
			enemy_node_name.get_node("anim").play(anim_name)
			
	# Turn enemy off
	var anim_name2 = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
	enemy_placeholder.get_node(anim_name2).visible = false

# Change state machine
func update_hp_number(anim_name):
	# Not interested in anything that isn't damage -> Replace later with state machine?
	if "death" in anim_name || "dodge" in anim_name:
		if BattlefieldInfo.combat_ai_unit != null:
			# Turn enemy off
			var anim_name2 = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
			enemy_placeholder.get_node(anim_name2).visible = false
		
		# Turn player off
		if BattlefieldInfo.combat_player_unit != null:
			var anim_name_off = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
			ally_placeholder.get_node(anim_name_off).visible = false
		return
	
	# Healing
	if "staff" in anim_name:
		enemy_hp_destination = BattlefieldInfo.combat_ai_unit.UnitStats.current_health + Combat_Calculator.player_healing_total
		
		# Clamp prevent going past max hp
		if enemy_hp_destination > BattlefieldInfo.combat_ai_unit.UnitStats.max_health:
			enemy_hp_destination = BattlefieldInfo.combat_ai_unit.UnitStats.max_health
		current_combat_state = player_healing_adjust
		previous_combat_state = wait
		return
	
	# For miss purposes
	enemy_hp_destination = BattlefieldInfo.combat_ai_unit.UnitStats.current_health
	player_hp_destination = BattlefieldInfo.combat_player_unit.UnitStats.current_health 
	
	# Update HP
	if previous_combat_state == player_first_turn:
		enemy_hp_destination = BattlefieldInfo.combat_ai_unit.UnitStats.current_health - Combat_Calculator.player_first_actual_damage
		current_combat_state = player_hp_first_update
		previous_combat_state = wait
	elif previous_combat_state == enemy_first_turn:
		player_hp_destination = BattlefieldInfo.combat_player_unit.UnitStats.current_health - Combat_Calculator.enemy_first_actual_damage
		current_combat_state = enemy_hp_first_update
		previous_combat_state = wait
	elif previous_combat_state == player_second_turn:
		enemy_hp_destination = BattlefieldInfo.combat_ai_unit.UnitStats.current_health - Combat_Calculator.player_second_actual_damage
		current_combat_state = player_hp_second_update
		previous_combat_state = wait
	elif enemy_second_turn:
		player_hp_destination = BattlefieldInfo.combat_player_unit.UnitStats.current_health - Combat_Calculator.enemy_second_actual_damage
		current_combat_state = enemy_hp_second_update
		previous_combat_state = wait
	
	# Clamp and play big death sound
	enemy_hp_destination = int(clamp(enemy_hp_destination, 0, 1000))
	player_hp_destination = int(clamp(player_hp_destination, 0, 1000))

func play_enemy_miss_anim():
	# Turn enemy off
	var anim_name2 = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
	enemy_placeholder.get_node(anim_name2).visible = false
	
	var weapon_used = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " dodge")
	enemy_node_name.get_node("anim").play(weapon_used)
	# Miss animation above the player
	$Miss_Player/anim.play("regular")

func play_player_miss_anim():
	# Turn player off
	var anim_name_off = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
	ally_placeholder.get_node(anim_name_off).visible = false
	
	var weapon_used = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " dodge")
	player_node_name.get_node("anim").play(weapon_used)
	$Miss_Enemy/anim.play("regular")

func turn_on():
	$"Combat Control".visible = true
	# Reduce volume of the music
	BattlefieldInfo.music_player.get_node("AllyLevel").volume_db = -8

	# Variable Reset
	player_hp_destination = 0
	enemy_hp_destination = 0

# Process Death
func process_ally_death():
	# we have a death text
	if BattlefieldInfo.combat_player_unit.death_sentence != null:
		BattlefieldInfo.message_system.set_position(Messaging_System.BOTTOM)
		BattlefieldInfo.message_system.start(BattlefieldInfo.combat_player_unit.death_sentence)
		current_combat_state = wait
		messaging_state = ally_death
	else:
		# No death text
		current_combat_state = wait
		player_node_name.get_node("anim").play(str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " death"))
		# Turn player off
		var anim_name_off = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
		ally_placeholder.get_node(anim_name_off).visible = false

func on_ally_death_complete():
	# Remove unit from the battle info
	BattlefieldInfo.ally_units.erase(BattlefieldInfo.combat_player_unit.UnitStats.identifier)
	
	# Clear Tile it is on
	BattlefieldInfo.combat_player_unit.UnitMovementStats.currentTile.occupyingUnit = null
	
	# Remove the ally units
	BattlefieldInfo.current_level.get_node("YSort").remove_child(BattlefieldInfo.combat_player_unit)
	
	# Did Eirika die? Game over ->
	if BattlefieldInfo.combat_player_unit.UnitStats.name == "Eirika":
		# Stop Music
		BattlefieldInfo.music_player.get_node("AllyLevel").stop()
		
		# Set game over status
		game_over = true
		
	elif BattlefieldInfo.battlefield_container.has_method("check_loss"):
		game_over = !BattlefieldInfo.battlefield_container.check_loss()

	# Back to Battlefield
	back_to_battlefield()

# Process Text function
func process_after_text():
	match messaging_state:
		before_fight:
			# Start combat normally
			BattlefieldInfo.combat_ai_unit.before_battle_sentence = null
			messaging_state = no_process
			$Pause.start(0)
		ally_death:
			player_node_name.get_node("anim").play(str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " death"))
			var anim_name2 = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
			ally_placeholder.get_node(anim_name2).visible = false
			current_combat_state = wait
			messaging_state = no_process
		after_fight:
			enemy_node_name.get_node("anim").play(str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " death"))
			var anim_name2 = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
			enemy_placeholder.get_node(anim_name2).visible = false
			messaging_state = no_process
			current_combat_state = wait
		no_process:
			pass

func process_enemy_death():
	# Do we have a death text
	if BattlefieldInfo.combat_ai_unit.death_sentence != null:
		BattlefieldInfo.message_system.set_position(Messaging_System.BOTTOM)
		BattlefieldInfo.message_system.start(BattlefieldInfo.combat_ai_unit.death_sentence)
		current_combat_state = wait
		messaging_state = after_fight
	else:
		# No Death Text
		enemy_node_name.get_node("anim").play(str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " death"))
		var anim_name2 = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " regular")
		enemy_placeholder.get_node(anim_name2).visible = false
		current_combat_state = wait

func on_enemy_death_complete():
	# Remove unit from battlefield info
	BattlefieldInfo.enemy_units.erase(BattlefieldInfo.combat_ai_unit.UnitStats.identifier)
	
	# Clear the tile it's on
	BattlefieldInfo.combat_ai_unit.UnitMovementStats.currentTile.occupyingUnit = null
	
	# Remove the node from the YSort
	BattlefieldInfo.current_level.get_node("YSort").remove_child(BattlefieldInfo.combat_ai_unit)
	
	# Process XP stuff here
	process_death_xp()

# Process XP and go to Level up screen if needed
func process_xp():
	# No going past level 20
	if BattlefieldInfo.combat_player_unit.UnitStats.level == 20:
		current_combat_state = wait
		back_to_battlefield()
		return
	
	$"Combat Control/Combat UI/XP Screen".visible = true
	# Total miss or no damage dealt at all
	if Combat_Calculator.player_first_actual_damage + Combat_Calculator.player_second_actual_damage <= 0:
		$"Combat Control/Combat UI/XP Screen".start_no_damage_or_miss()
	else:
		$"Combat Control/Combat UI/XP Screen".start()
	
	current_combat_state = wait

func process_heal_xp():
	# No going past level 20
	if BattlefieldInfo.combat_player_unit.UnitStats.level == 20:
		current_combat_state = wait
		back_to_battlefield()
		return
	$"Combat Control/Combat UI/XP Screen".visible = true
	$"Combat Control/Combat UI/XP Screen".start_heal_xp()

func process_death_xp():
	# No going past level 20
	if BattlefieldInfo.combat_player_unit.UnitStats.level == 20:
		current_combat_state = wait
		back_to_battlefield()
		return
	
	$"Combat Control/Combat UI/XP Screen".visible = true
	current_combat_state = wait
	$"Combat Control/Combat UI/XP Screen".start_death()


func back_to_battlefield():
	$"Return Pause".start(0)
	
	# Set to wait
	previous_combat_state = wait
	current_combat_state = wait

func turn_off():
	# Remove XP Bar
	$"Combat Control/Combat UI/XP Screen".visible = false
	$"Combat Control/Combat UI/Item Broke Screen".visible = false
	
	# Item broke cancel
	broke_item = false
	
	# Cinematic purposes
	if cinematic_branch:
		cinematic_branch = false
		
		emit_signal("combat_screen_done")
	
	# Turn on the highlights again
	if highlight_positions:
		for enemy in BattlefieldInfo.enemy_units.values():
				BattlefieldInfo.movement_calculator.highlight_enemy_movement_range(enemy, BattlefieldInfo.grid)
		BattlefieldInfo.cursor.enemy_position_state = false
	highlight_positions = false
	
	
	# If this is a game over
	if game_over:
		BattlefieldInfo.game_over = true
	BattlefieldInfo.turn_manager.emit_signal("check_end_turn")

# Pause
func _on_Pause_timeout():
	current_combat_state = next_combat_state
	previous_combat_state = next_combat_state

func _on_Return_Pause_timeout():
	set_process(false)
	
	# Cinematic Branch
	if !cinematic_branch:
		# Start Music
		if BattlefieldInfo.turn_manager.turn == Turn_Manager.PLAYER_TURN:
			# Set the ally unit to done status | Greyscale if not dead
			if !weakref(BattlefieldInfo.combat_player_unit):
				BattlefieldInfo.combat_player_unit.get_node("Animation").play("Idle")
				BattlefieldInfo.combat_player_unit.UnitActionStatus.current_action_status = Unit_Action_Status.DONE
				BattlefieldInfo.combat_player_unit.turn_greyscale_on()
			
			# Cursor
			# Set Cursor back to move
			BattlefieldInfo.current_Unit_Selected = null
			BattlefieldInfo.cursor.enable_standard()
		
		# AI
		if BattlefieldInfo.turn_manager.turn == Turn_Manager.ENEMY_COMBAT_TURN:
			# If not dead, turn greyscale on
			if !weakref(BattlefieldInfo.combat_ai_unit):
				BattlefieldInfo.combat_ai_unit.UnitActionStatus.current_action_status = Unit_Action_Status.DONE
				BattlefieldInfo.combat_ai_unit.turn_greyscale_on()
			BattlefieldInfo.turn_manager.turn = Turn_Manager.ENEMY_TURN
			
			# For Cursor purposes
			BattlefieldInfo.current_Unit_Selected = null
			
	else:
		# Cinematic stuff
		BattlefieldInfo.current_Unit_Selected = null
		BattlefieldInfo.turn_manager.turn = Turn_Manager.WAIT
	
	# Reactive all ally and enemy units left
	# Turn off Units
	for ally_unit in BattlefieldInfo.ally_units.values():
		ally_unit.visible = true
	
	for enemy_unit in BattlefieldInfo.enemy_units.values():
		enemy_unit.visible = true
		
	# Music Volume Back to Normal
	BattlefieldInfo.music_player.get_node("anim").play("Volume Up")
	
	# Common to both
	# Turn off modulate
	BattlefieldInfo.current_level.get_node("Anim").play("Fade 0.5")
	
	# Fade away
	$Anim.play("Fade")
	yield($Anim, "animation_finished")
	
	# Disable arrows
	$"Combat Control/Combat UI/Enemy/Enemy Up Arrow Combat".visible = false
	$"Combat Control/Combat UI/Enemy/Enemy Down Arrow Combat".visible = false
	$"Combat Control/Combat UI/Player/Player Down Arrow Combat".visible = false
	$"Combat Control/Combat UI/Player/Player Up Arrow Combat".visible = false
	
	# Disable this
	$"Combat Control".visible = false
	
	# Disable xp if it's on
	$"Combat Control/Combat UI/Level Up Screen".visible = false
	
	# Turn off all the animations
	enemy_node_name.turn_off()
	player_node_name.turn_off()
	
	# Clear the combat nodes
	enemy_node_name.queue_free()
	player_node_name.queue_free()
	ally_placeholder.queue_free()
	enemy_placeholder.queue_free()
	
	# Remove the orphan nodes
	# Enemy
	if BattlefieldInfo.combat_ai_unit.UnitStats.current_health <= 0:
		BattlefieldInfo.combat_ai_unit.queue_free()
	
	# Ally
	if BattlefieldInfo.combat_player_unit.UnitStats.current_health <= 0:
		BattlefieldInfo.combat_player_unit.queue_free()
	
	# Reset Messaging State and Combat State
	current_combat_state = wait
	previous_combat_state = wait
	messaging_state = no_process
	
	# Disable
	turn_off()
