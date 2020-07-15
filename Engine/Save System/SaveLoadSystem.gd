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
	
	# Save units
	save_player_units(save_game_file)
	
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
	
	# Load all data from the file
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
	
	# Set new commander name
	BattlefieldInfo.level_container.enemy_commander_name = data["enemy_commander_name"]
	
	# Clear all the events
	BattlefieldInfo.event_system.clear()
	
	# Set turn level number
	data = saved_data[2]
	BattlefieldInfo.turn_manager.player_turn_number = data["player_turn"]
	BattlefieldInfo.turn_manager.enemy_turn_number = data["enemy_turn"]
	
	# Load Units
	# Clear Allies
	for ally_unit in BattlefieldInfo.ally_units.values():
		# Clear the cell they are on
		if ally_unit.UnitMovementStats.currentTile != null:
			ally_unit.UnitMovementStats.currentTile.occupyingUnit = null
		ally_unit.free()
	BattlefieldInfo.ally_units.clear()
	
	# Clear Enemies
	for enemy_unit in BattlefieldInfo.enemy_units.values():
		# Clear cell they are on
		if enemy_unit.UnitMovementStats.currentTile != null:
			enemy_unit.UnitMovementStats.currentTile.occupyingUnit = null
		enemy_unit.free()
	BattlefieldInfo.enemy_units.clear()
	
	data = saved_data[3]
	for ally_unit in data["player_units"]:
		# Data objects needed
		var node_data = ally_unit["node_info"]
		var vector2_data = ally_unit["vector2"]
		var unit_movement_data = ally_unit["unit_movement_stats"]
		var action_status_data = ally_unit["action_status"]
		var unit_stats_data = ally_unit["unit_stats"]
		var unit_inventory_data = ally_unit["inventory_data"]
		
		# Create ally
		var player_object = load(node_data["filename"]).instance()
		player_object.name = unit_stats_data["identifier"]
		
		# Attach back to the y sort
		get_node(node_data["parent"]).add_child(player_object)
		
		# Set position and cell data
		player_object.position = Vector2(vector2_data["pos_x"], vector2_data["pos_y"])
		
		# Inventory
		# Clear the current inventory
		player_object.UnitInventory.clear_inventory()
		
		# Create new inventory objects
		for item_data in unit_inventory_data:
			var item_object = load(item_data["filename"]).instance()
			player_object.UnitInventory.add_item(item_object)
			item_object.load_item(item_data["item_stats"])
		
		# Unit Stats
		for unit_stat_key in unit_stats_data.keys():
			if typeof(unit_stats_data[unit_stat_key]) == TYPE_REAL:
				player_object.UnitStats.set(unit_stat_key, int(unit_stats_data[unit_stat_key]))
			else:
				player_object.UnitStats.set(unit_stat_key, unit_stats_data[unit_stat_key])
		
		# Set current tile
		if player_object.UnitMovementStats.currentTile == null:
			if player_object.position.x >= 0 && player_object.position.y >= 0:
				player_object.UnitMovementStats.currentTile = BattlefieldInfo.grid[player_object.position.x / Cell.CELL_SIZE][player_object.position.y / Cell.CELL_SIZE]
				BattlefieldInfo.grid[player_object.position.x / Cell.CELL_SIZE][player_object.position.y / Cell.CELL_SIZE].occupyingUnit = player_object
		
		# Movement Stats
		for unit_movement_stat_key in unit_movement_data.keys():
			if unit_movement_stat_key == "is_ally":
				player_object.UnitMovementStats.set(unit_movement_stat_key, unit_movement_data[unit_movement_stat_key])
			else:
				player_object.UnitMovementStats.set(unit_movement_stat_key, int(unit_movement_data[unit_movement_stat_key]))
		
		# Unit action status
		player_object.UnitActionStatus.set_current_action_index(int(action_status_data["current_action_status"]))
		if player_object.UnitActionStatus.current_action_status == Unit_Action_Status.DONE:
			player_object.turn_greyscale_on()
		
		# Set Death and battle quotes
		var battle_quotes_data = ally_unit["battle_quotes"]
		if battle_quotes_data["before_battle_sentence"] != null:
			player_object.before_battle_sentence = battle_quotes_data["before_battle_sentence"]
		
		if battle_quotes_data["death_sentence"] != null:
			player_object.death_sentence = battle_quotes_data["death_sentence"]
		
		# Check if it's an enemy or ally
		if !player_object.UnitMovementStats.is_ally:
			# Set AI
			# Remove the old AI
			player_object.get_node("AI").free()
			
			# Create AI object
			var ai_data = ally_unit["AI"]
			var ai_object = load(ai_data["filename"]).instance()
			ai_object.name = "AI"
			
			# Set AI Type
			ai_object.ai_type = ai_data["ai_type"]
			
			# Add AI
			player_object.add_child(ai_object)
			
			# Add to the enemy array
			BattlefieldInfo.enemy_units[player_object.UnitStats.identifier] = player_object
			
		else:
			# Add to the array
			BattlefieldInfo.ally_units[player_object.UnitStats.identifier] = player_object
	
	# Set new eirika
	BattlefieldInfo.Eirika = BattlefieldInfo.ally_units["Eirika"]
	
	# Set new enemy commander
	BattlefieldInfo.enemy_commander = BattlefieldInfo.enemy_units[BattlefieldInfo.level_container.enemy_commander_name]
	
	# Load events
	data = saved_data[4]
	BattlefieldInfo.event_system.clear()
	
	# Starting events
	for s_event in data["starting_events"]:
		var event_object = load(s_event["filename"]).new()
		BattlefieldInfo.event_system.add_event(event_object)
	
	# Mid Event
	for m_event in data["mid_events"]:
		var event_object = load(m_event["filename"]).new()
		BattlefieldInfo.event_system.add_mid_event(event_object)
	
	# Load elapsed time
	data = saved_data[5]
	StatusScreen.saved_time = int(data)
	
	# Load Convoy
	data = saved_data[6]
	BattlefieldInfo.convoy.load_convoy(data)
	
	# Start game
	# Is there a prep mode?
	if BattlefieldInfo.event_system.queue_of_events.size() == 0:
		BattlefieldInfo.event_system.start_events_queue()
	else:
		BattlefieldInfo.level_container.preperation_mode()
	
	# Signal game is loaded
	emit_signal("loading_complete")

func save_player_units(save_game_file):
	print("Saving player units...")
	
	var player_array = {"player_units" : []}
	
	# Units in the current level units
	for player_unit in BattlefieldInfo.current_level.get_node("YSort").get_children():
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
	
	# Units in the y sort of the battlefield
	for player_unit in BattlefieldInfo.y_sort_player_party.get_children():
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
	

func save_current_events(save_game_file):
	print("Saving current events...")
	save_game_file.store_line(to_json(BattlefieldInfo.event_system.save()))
	

func save_convoy(save_game_file):
	print("Saving convoy...")
	var convoy_save_data = BattlefieldInfo.convoy.save()
	save_game_file.store_line(to_json(convoy_save_data))

func save_money(save_game_file):
	print("Saving money...")
	var money = {"money": BattlefieldInfo.money}
	save_game_file.store_line(to_json(money))

func save_current_play_time(save_game_file):
	print("Saving current play time...")
	var total_elapsed_time = StatusScreen.current_play_session + StatusScreen.saved_time
	save_game_file.store_line(to_json(total_elapsed_time))

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
		"enemy_commander_name": BattlefieldInfo.level_container.enemy_commander_name
	}
	save_game_file.store_line(to_json(current_level))
