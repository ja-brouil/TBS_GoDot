extends Node

class_name SaveLoadSystem
# Save and load the game here

# Signal to emit when loading/saving is done
signal loading_complete
signal saving_complete

# Loading a level
var is_loading_level = false

func save_game():
	# Save player Units
	print("Starting to save...")
	
	# Open new file
	var save_game_file = File.new()
	save_game_file.open("res://Save/save_game_file.save", File.WRITE)
	
	# Save current money
	save_money(save_game_file)
	
	# Save current level
	save_current_level(save_game_file)
	
	# Save turn number
	save_turn_number(save_game_file)
	
	# Player units
	save_player_units(save_game_file)
	
	# Save enemy units
	save_enemy_units(save_game_file)
	
	# Save current events left
	save_current_events(save_game_file)
	
	# Save current play time
	save_current_play_time(save_game_file)
	
	# Save the convoy
	save_convoy(save_game_file)
	
	# Close File stream
	save_game_file.close()
	emit_signal("saving_complete")
	print("Save complete!")

func load_game():
	# Check if we have a save file
	var saved_game = File.new()
	if !saved_game.file_exists("res://Save/save_game_file.save"):
		print("No save file found!")
		return
	
	# Loading process
	var saved_data = []
	
	# Load file
	saved_game.open("res://Save/save_game_file.save", File.READ)
	
	# Set money of the game
	while saved_game.get_position() < saved_game.get_len():
		var node_data = parse_json(saved_game.get_line())
		saved_data.append(node_data)
	
	# Reverse the loading process
	# Money
	var data = saved_data[0]
	BattlefieldInfo.money = data["money"]
	
	# Load level
	data = saved_data[1]
	# Create level
	var level_object = load(data["filename"]).instance()
	get_node(data["parent"]).add_child(level_object)
	
	# Clear all the events
	BattlefieldInfo.event_system.clear()
	
	# Set turn level number
	data = saved_data[2]
	BattlefieldInfo.turn_manager.player_turn_number = data["player_turn"]
	BattlefieldInfo.turn_manager.enemy_turn_number = data["enemy_turn"]
	
	# Load player units
	for ally_unit in BattlefieldInfo.ally_units.values():
		# Clear the cell they are on
		ally_unit.UnitMovementStats.currentTile.occupyingUnit = null
		ally_unit.free()
	BattlefieldInfo.ally_units.clear()
	
	data = saved_data[3]
	for ally_unit in data["player_units"]:
		# Create ally
		var player_object = load(ally_unit["filename"]).instance()
		player_object.name = ally_unit["unit_identifier"]
		
		# Attach back to the y sort
		get_node(ally_unit["parent"]).add_child(player_object)
		
		# Set position and cell data
		player_object.position = Vector2(ally_unit["pos_x"], ally_unit["pos_y"])
		
		# Do inventory here
		
		# Unit Stats
		player_object.UnitStats.level = ally_unit["unit_level"]
		player_object.UnitStats.current_health = ally_unit["current_health"]
		player_object.UnitStats.max_health = ally_unit["max_health"]
		player_object.UnitStats.pegasus = ally_unit["pegasus"]
		player_object.UnitStats.skill = ally_unit["skill"]
		player_object.UnitStats.bonus_crit = ally_unit["bonus_crit"]
		player_object.UnitStats.luck = ally_unit["luck"]
		player_object.UnitStats.def = ally_unit["defence"]
		player_object.UnitStats.magic = ally_unit["magic"]
		player_object.UnitStats.consti = ally_unit["consti"]
		player_object.UnitStats.bonus_hit = ally_unit["bonus_hit"]
		player_object.UnitStats.bonus_dodge = ally_unit["bonus_dodge"]
		player_object.UnitStats.current_xp = ally_unit["current_xp"]
		player_object.UnitStats.class_bonus_a = ally_unit["class_bonus_a"]
		player_object.UnitStats.class_power = ally_unit["class_power"]
		player_object.UnitStats.class_bonus_b = ally_unit["class_bonus_b"]
		player_object.UnitStats.class_type = ally_unit["class_type"]
		player_object.UnitStats.boss_bonus = ally_unit["boss_bonus"]
		player_object.UnitStats.identifier = ally_unit["unit_identifier"]
		player_object.UnitStats.thief_bonus = ally_unit["thief_bonus"]
		player_object.UnitStats.str_chance = ally_unit["str_chance"]
		player_object.UnitStats.skill_chance = ally_unit["skill_chance"]
		player_object.UnitStats.speed_chance = ally_unit["speed_chance"]
		player_object.UnitStats.magic_chance = ally_unit["magic_chance"]
		player_object.UnitStats.luck_chance = ally_unit["luck_chance"]
		player_object.UnitStats.def_chance = ally_unit["def_chance"]
		player_object.UnitStats.res_chance = ally_unit["res_chance"]
		player_object.UnitStats.consti_chance = ally_unit["consti_chance"]
		player_object.UnitStats.max_health_chance = ally_unit["max_health_chance"]
		player_object.UnitStats.horse = ally_unit["horse"]
		player_object.UnitStats.armor = ally_unit["armor"]
		player_object.UnitStats.name = ally_unit["name"]
		player_object.UnitStats.res = ally_unit["resistance"]
		player_object.UnitStats.speed = ally_unit["speed"]
		player_object.UnitStats.strength = ally_unit["strength"]
		
		# Movement stats
		# Set current tile
		player_object.UnitMovementStats.currentTile = BattlefieldInfo.grid[player_object.position.x / Cell.CELL_SIZE][player_object.position.y / Cell.CELL_SIZE]
		BattlefieldInfo.grid[player_object.position.x / Cell.CELL_SIZE][player_object.position.y / Cell.CELL_SIZE].occupyingUnit = player_object
		player_object.UnitMovementStats.movementSteps = ally_unit["movementSteps"]
		player_object.UnitMovementStats.is_ally = ally_unit["is_ally"]
		player_object.UnitMovementStats.defaultPenalty = ally_unit["default_penalty"]
		player_object.UnitMovementStats.mountainPenalty = ally_unit["mountain_penalty"]
		player_object.UnitMovementStats.hillPenalty = ally_unit["hill_penalty"]
		player_object.UnitMovementStats.forestPenalty = ally_unit["forest_penalty"]
		player_object.UnitMovementStats.fortressPenalty = ally_unit["fortress_penalty"]
		player_object.UnitMovementStats.buildingPenalty = ally_unit["building_penalty"]
		player_object.UnitMovementStats.riverPenalty = ally_unit["river_penalty"]
		player_object.UnitMovementStats.seaPenalty = ally_unit["sea_penalty"]
		
		# Unit action status
		player_object.UnitActionStatus.set_current_action_index(int(ally_unit["current_action_status"]))
		if player_object.UnitActionStatus.current_action_status == Unit_Action_Status.DONE:
			player_object.turn_greyscale_on()
		
		# Add to the array
		BattlefieldInfo.ally_units[player_object.UnitStats.identifier] = player_object
	
	# Set new eirika
	BattlefieldInfo.Eirika = BattlefieldInfo.ally_units["Eirika"]
	
	# Load Enemy Units
	for enemy_unit in BattlefieldInfo.enemy_units.values():
		# Clear the cell they are on
		enemy_unit.UnitMovementStats.currentTile.occupyingUnit = null
		enemy_unit.free()
	BattlefieldInfo.enemy_units.clear()
	
	data = saved_data[4]
	for enemy_unit in data["enemy_units"]:
		# Create enemy
		var enemy_object = load(enemy_unit["filename"]).instance()
		enemy_object.name = enemy_unit["unit_identifier"]
		
		# Attach back to the y sort
		get_node(enemy_unit["parent"]).add_child(enemy_object)
		
		# Set position and cell data
		enemy_object.position = Vector2(enemy_unit["pos_x"], enemy_unit["pos_y"])
		
		# Do inventory here
		
		# Unit Stats
		enemy_object.UnitStats.level = enemy_unit["unit_level"]
		enemy_object.UnitStats.current_health = enemy_unit["current_health"]
		enemy_object.UnitStats.max_health = enemy_unit["max_health"]
		enemy_object.UnitStats.pegasus = enemy_unit["pegasus"]
		enemy_object.UnitStats.skill = enemy_unit["skill"]
		enemy_object.UnitStats.bonus_crit = enemy_unit["bonus_crit"]
		enemy_object.UnitStats.luck = enemy_unit["luck"]
		enemy_object.UnitStats.def = enemy_unit["defence"]
		enemy_object.UnitStats.magic = enemy_unit["magic"]
		enemy_object.UnitStats.consti = enemy_unit["consti"]
		enemy_object.UnitStats.bonus_hit = enemy_unit["bonus_hit"]
		enemy_object.UnitStats.bonus_dodge = enemy_unit["bonus_dodge"]
		enemy_object.UnitStats.current_xp = enemy_unit["current_xp"]
		enemy_object.UnitStats.class_bonus_a = enemy_unit["class_bonus_a"]
		enemy_object.UnitStats.class_power = enemy_unit["class_power"]
		enemy_object.UnitStats.class_bonus_b = enemy_unit["class_bonus_b"]
		enemy_object.UnitStats.class_type = enemy_unit["class_type"]
		enemy_object.UnitStats.boss_bonus = enemy_unit["boss_bonus"]
		enemy_object.UnitStats.identifier = enemy_unit["unit_identifier"]
		enemy_object.UnitStats.thief_bonus = enemy_unit["thief_bonus"]
		enemy_object.UnitStats.str_chance = enemy_unit["str_chance"]
		enemy_object.UnitStats.skill_chance = enemy_unit["skill_chance"]
		enemy_object.UnitStats.speed_chance = enemy_unit["speed_chance"]
		enemy_object.UnitStats.magic_chance = enemy_unit["magic_chance"]
		enemy_object.UnitStats.luck_chance = enemy_unit["luck_chance"]
		enemy_object.UnitStats.def_chance = enemy_unit["def_chance"]
		enemy_object.UnitStats.res_chance = enemy_unit["res_chance"]
		enemy_object.UnitStats.consti_chance = enemy_unit["consti_chance"]
		enemy_object.UnitStats.max_health_chance = enemy_unit["max_health_chance"]
		enemy_object.UnitStats.horse = enemy_unit["horse"]
		enemy_object.UnitStats.armor = enemy_unit["armor"]
		enemy_object.UnitStats.name = enemy_unit["name"]
		enemy_object.UnitStats.res = enemy_unit["resistance"]
		enemy_object.UnitStats.speed = enemy_unit["speed"]
		enemy_object.UnitStats.strength = enemy_unit["strength"]
		
		# Movement stats
		# Set current tile
		enemy_object.UnitMovementStats.currentTile = BattlefieldInfo.grid[enemy_object.position.x / Cell.CELL_SIZE][enemy_object.position.y / Cell.CELL_SIZE]
		BattlefieldInfo.grid[enemy_object.position.x / Cell.CELL_SIZE][enemy_object.position.y / Cell.CELL_SIZE].occupyingUnit = enemy_object
		enemy_object.UnitMovementStats.movementSteps = enemy_unit["movementSteps"]
		enemy_object.UnitMovementStats.is_ally = enemy_unit["is_ally"]
		enemy_object.UnitMovementStats.defaultPenalty = enemy_unit["default_penalty"]
		enemy_object.UnitMovementStats.mountainPenalty = enemy_unit["mountain_penalty"]
		enemy_object.UnitMovementStats.hillPenalty = enemy_unit["hill_penalty"]
		enemy_object.UnitMovementStats.forestPenalty = enemy_unit["forest_penalty"]
		enemy_object.UnitMovementStats.fortressPenalty = enemy_unit["fortress_penalty"]
		enemy_object.UnitMovementStats.buildingPenalty = enemy_unit["building_penalty"]
		enemy_object.UnitMovementStats.riverPenalty = enemy_unit["river_penalty"]
		enemy_object.UnitMovementStats.seaPenalty = enemy_unit["sea_penalty"]
		
		# Unit action status
		enemy_object.UnitActionStatus.set_current_action_index(int(enemy_unit["current_action_status"]))
		if enemy_object.UnitActionStatus.current_action_status == Unit_Action_Status.DONE:
			enemy_object.turn_greyscale_on()
		
		# Set AI
		# Remove the old AI
		enemy_object.get_node("AI").free()
		
		# Create AI object
		var ai_data = enemy_unit["AI"]
		var ai_object = load(ai_data["filename"]).instance()
		ai_object.name = "AI"
		
		# Set AI Type
		ai_object.ai_type = ai_data["ai_type"]
		
		# Add AI
		enemy_object.add_child(ai_object)
		
		# Add to enemy array
		BattlefieldInfo.enemy_units[enemy_object.UnitStats.identifier] = enemy_object
		
	# load the convoy here
	
	# load events
	
	# Start music
	
	BattlefieldInfo.event_system.start_events_queue()

func save_player_units(save_game_file):
	print("Saving player units...")
	
	var player_array = {"player_units" : []}
	
	# Player units
	for player_unit in BattlefieldInfo.get_node("YSort").get_children():
		# Make sure node is an instanced scene
		if player_unit.filename.empty():
			print("Persistent node '%s' is not an instanced scene, skipped." % player_unit.name)
			continue
		
		# Check if there is a save function
		if !player_unit.has_method("save"):
			print("Persistent node '%s' is missing save() function, skipped." % player_unit.name)
			continue
		
		# Call the node's save function
		var unit_data = player_unit.save()
		
		player_array["player_units"].append(unit_data)
		
	# Save Data
	save_game_file.store_line(to_json(player_array))
		

func save_enemy_units(save_game_file):
	print("Saving enemy units...")
	
	var enemy_array = {"enemy_units" : []}
	
	# Enemy Units
	for enemy_unit in BattlefieldInfo.current_level.get_node("YSort").get_children():
		# Make sure node is an instanced scene
		if enemy_unit.filename.empty():
			print("Persistent node '%s' is not an instanced scene, skipped." % enemy_unit.name)
			continue
		
		# Check if there is a save function
		if !enemy_unit.has_method("save"):
			print("Persistent node '%s' is missing save() function, skipped." % enemy_unit.name)
			continue
		
		# Call the node's save function
		var unit_data = enemy_unit.save()
		
		enemy_array["enemy_units"].append(unit_data)
		
	# Save Data
	save_game_file.store_line(to_json(enemy_array))

func save_current_events(save_game_file):
	print("Saving current events...")

func save_convoy(save_game_file):
	print("Saving convoy...")

func save_money(save_game_file):
	print("Saving money...")
	var money = {"money": BattlefieldInfo.money}
	save_game_file.store_line(to_json(money))

func save_current_play_time(save_game_file):
	print("Saving current play time...")

func save_turn_number(save_game_file):
	print("Saving current turn manager")
	var turn_manager_number = {
		"player_turn" : BattlefieldInfo.turn_manager.player_turn_number,
		"enemy_turn" : BattlefieldInfo.turn_manager.enemy_turn_number
	}
	save_game_file.store_line(to_json(turn_manager_number))

func save_current_level(save_game_file):
	print("Saving current level...")
	var current_level = {
		"filename" : BattlefieldInfo.level_container.get_filename(),
		"parent": BattlefieldInfo.level_container.get_parent().get_path(),
	}
	save_game_file.store_line(to_json(current_level))
