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
const SPEED = 10

# Music Playback
var ally_song_location = 0
var enemy_song_location = 0

# Update hp + variables needed
enum {player_first_turn, player_hp_first_update, enemy_first_turn, enemy_hp_first_update, player_second_turn, player_hp_second_update, enemy_second_turn, enemy_hp_second_update, player_death, enemy_death, wait}
var current_combat_state = wait
var previous_combat_state = wait
var next_combat_state
var player_hp_destination = 0
var enemy_hp_destination = 0

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
					if BattlefieldInfo.combat_player_unit.UnitStats.current_health == 0:
						print("COMBAT SCREEN ANIM: Player Unit has died!")
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
					if BattlefieldInfo.combat_ai_unit.UnitStats.current_health == 0:
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
					if BattlefieldInfo.combat_player_unit.UnitStats.current_health == 0:
						print("COMBAT SCREEN ANIM: Player Unit has died!")
						# EXIT
				# We are done here. so to test, just turn off everything and remove
			player_death:
				pass
			enemy_death:
				process_enemy_death()
				return
			wait:
				pass
	elif BattlefieldInfo.turn_manager.turn == Turn_Manager.ENEMY_TURN:
		pass
	# Enemy Turn Reverse the above code basically
	

# Combat Process
func start_combat(current_combat_state): 
	# Process actual numbers
	Combat_Calculator.process_player_combat()
	Combat_Calculator.process_enemy_combat()
	
	# Set destination to 0
	player_hp_destination = 0
	enemy_hp_destination = 0
	
	# Turn off units and background
	get_parent().get_parent().get_node("Level").set_modulate(Color(1,1,1,0.5))
	
	# Turn off Units
	for ally_unit in BattlefieldInfo.ally_units:
		ally_unit.visible = false
	
	for enemy_unit in BattlefieldInfo.enemy_units:
		enemy_unit.visible = false
	
	# Place appropriate combat art
	place_combat_art()
	
	# Adjust GUI Box
	adjust_gui_text_and_hp_box()
	
	# Set Background
	set_background(BattlefieldInfo.combat_player_unit.UnitMovementStats.currentTile.tileName)
	
	# Turn on
	turn_on()
	
	# Set Next
	next_combat_state = current_combat_state
	
	# Set states to start
	$Pause.start(0)

# Get the appropriate art
func place_combat_art():
	# Player
	player_node_name = BattlefieldInfo.combat_player_unit.combat_node.instance()
	player_node_name.position = $"Ally Unit".position
	
	# Player Animation Signals
	player_node_name.connect("play_enemy_dodge_anim", self, "play_enemy_miss_anim")
	player_node_name.connect("death_anim_done", self, "on_ally_death_complete")
	player_node_name.get_node("anim").connect("animation_finished", self, "update_hp_number")
	add_child(player_node_name)
	
	# Enemy
	enemy_node_name = BattlefieldInfo.combat_ai_unit.combat_node.instance()
	enemy_node_name.position = $"Enemy Unit".position
	
	# Enemy Miss signal
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

# Change state machine
func update_hp_number(anim_name):
	# Not interested in anything that isn't damage -> Replace later with state machine?
	if anim_name == "death" || "dodge" in anim_name:
		# Unit has died, we exit right away
		return
	
	# For miss purposes
	enemy_hp_destination = BattlefieldInfo.combat_ai_unit.UnitStats.current_health
	player_hp_destination = BattlefieldInfo.combat_player_unit.UnitStats.current_health 
	
	# Exit early if dodge/miss
	if "miss" in anim_name:
		if previous_combat_state == enemy_first_turn:
			current_combat_state = enemy_hp_first_update
			previous_combat_state = wait
		elif previous_combat_state == player_second_turn:
			current_combat_state = player_hp_second_update
			previous_combat_state = wait
		elif enemy_second_turn:
			current_combat_state = enemy_hp_second_update
			previous_combat_state = wait
	else:
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
	var weapon_used = str(BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.weapon_string_name, " dodge")
	enemy_node_name.get_node("anim").play(weapon_used)

func play_player_miss_anim():
	var weapon_used = str(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.weapon_string_name, " dodge")
	player_node_name.get_node("anim").play(weapon_used)

func turn_on():
	$"Combat Control".visible = true
	# Stop current music
	if BattlefieldInfo.turn_manager.turn == Turn_Manager.PLAYER_TURN:
		if BattlefieldInfo.enemy_units.size() <= 1:
			BattlefieldInfo.music_player.get_node("OneUnitLeft").stop()
		BattlefieldInfo.music_player.get_node("AllyLevel").stop()
	else:
		BattlefieldInfo.music_player.get_node("EnemyLevel").stop()
	
	# Start music
#	if BattlefieldInfo.turn_manager.turn == Turn_Manager.PLAYER_TURN:
#		BattlefieldInfo.music_player.get_node("Ally Combat").play(0)
#	else:
#		BattlefieldInfo.music_player.get_node("Enemy Combat").play(0)
	
	$CombatM.play(0)
	
	# Variable Reset
	player_hp_destination = 0
	enemy_hp_destination = 0

# Process Death
func process_ally_death():
	pass

func on_ally_death_complete():
	pass

func process_enemy_death():
	enemy_node_name.get_node("anim").play("death")
	current_combat_state = wait
	
	$CombatM.stop()
	$Victory.play(0)

func on_enemy_death_complete():
	# Remove unit from battlefield info
	BattlefieldInfo.enemy_units.erase(BattlefieldInfo.combat_ai_unit)
	
	# Clear the tile it's on
	BattlefieldInfo.combat_ai_unit.UnitMovementStats.currentTile.occupyingUnit = null
	
	# Remove the unit from the world
	BattlefieldInfo.combat_ai_unit.queue_free()
	
	# Process XP stuff here
	process_xp()
	
	# Back to the world map
	back_to_battlefield()

# We need to wait here for this to finish, there might be a level up screen as well
func process_xp():
	print("From Combat Screen: XP Processed")
	
	# Back to battlefield
	back_to_battlefield()

func back_to_battlefield():
	$"Return Pause".start(0)
	
	# Set to wait
	previous_combat_state = wait
	current_combat_state = wait

func turn_off():
	# Stop Music
	if BattlefieldInfo.turn_manager.turn == Turn_Manager.PLAYER_TURN:
		if BattlefieldInfo.enemy_units.size() <= 1:
			ally_song_location = BattlefieldInfo.music_player.get_node("OneUnitLeft").get_playback_position()
		else:
			ally_song_location = BattlefieldInfo.music_player.get_node("AllyLevel").get_playback_position()
		BattlefieldInfo.music_player.get_node("Ally Combat").stop()
	else:
		enemy_song_location = BattlefieldInfo.music_player.get_node("EnemyLevel").get_playback_position()
		BattlefieldInfo.music_player.get_node("Enemy Combat").stop()
	

# Pause
func _on_Pause_timeout():
	current_combat_state = next_combat_state
	previous_combat_state = next_combat_state

func _on_Return_Pause_timeout():
	# REMOVE THIS
	$Victory.stop()
	$CombatM.stop()
	
	# Remove any units that are still alive
	if player_node_name != null:
		player_node_name.queue_free()
	
	if enemy_node_name != null:
		enemy_node_name.queue_free()
	
	# Set Cursor back to move
	get_parent().get_parent().get_node("Cursor").enable_standard()
	
	# Start Music
	if BattlefieldInfo.turn_manager.turn == Turn_Manager.PLAYER_TURN:
		if BattlefieldInfo.enemy_units.size() <= 1:
			BattlefieldInfo.music_player.get_node("OneUnitLeft").play(ally_song_location)
		else:
			BattlefieldInfo.music_player.get_node("AllyLevel").play(ally_song_location)
	else:
		BattlefieldInfo.music_player.get_node("EnemyLevel").play(enemy_song_location)
	
	# Turn off modulate
	get_parent().get_parent().get_node("Level").modulate = Color(1, 1, 1, 1)
	
	# Reactive all ally and enemy units left
	# Turn off Units
	for ally_unit in BattlefieldInfo.ally_units:
		ally_unit.visible = true
	
	for enemy_unit in BattlefieldInfo.enemy_units:
		enemy_unit.visible = true
	
	# Disable this
	$"Combat Control".visible = false
	
	# Set unit state to done
	# Set the ally unit to done status | Greyscale
	BattlefieldInfo.combat_player_unit.get_node("Animation").play("Idle")
	BattlefieldInfo.combat_player_unit.UnitActionStatus.current_action_status = Unit_Action_Status.DONE
	BattlefieldInfo.combat_player_unit.turn_greyscale_on()
	
	# Disable
	turn_off()