extends CanvasLayer

# Reachable enemies
var reachable_enemies_list = []
var current_option_selected
var current_number_selected = 0

# Left/Right side constants
const RIGHT_SIDE = Vector2(140,0)
const LEFT_SIDE = Vector2(0,0)

# Tile highlight
var highlight_tiles = []

# Item that was selected
var selected_item

# Activate input
var is_active

func _ready():
	is_active = false

# Input
func _input(event):
	if !is_active:
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		print("FROM DAMAGE PREVIEW: Go to combat screen")
		$"Hand Selector/Accept".play(0)
		process_selection()
	elif Input.is_action_just_pressed("ui_cancel"):
		$"Hand Selector/Cancel".play(0)
		go_back()
	elif Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_right"):
		current_number_selected -= 1
		if current_number_selected < 0:
			current_number_selected = reachable_enemies_list.size() - 1
		$"Hand Selector/Move".play(0)
		update_enemy_chosen()
		update_preview_box()
	elif Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("ui_left"):
		current_number_selected += 1
		if current_number_selected >= reachable_enemies_list.size():
			current_number_selected = 0
		$"Hand Selector/Move".play(0)
		update_enemy_chosen()
		update_preview_box()


# Start
func start(item):
	# Set item
	selected_item = item
	
	# Set battle combat unit
	BattlefieldInfo.combat_player_unit = BattlefieldInfo.current_Unit_Selected
	
	# Get all available units that can be attacked with this item range
	get_reachable_enemies()
	
	# Reset stats
	current_number_selected = 0
	current_option_selected = reachable_enemies_list[current_number_selected]
	
	# Update cursor
	update_enemy_chosen()
	
	# Update Box
	update_preview_box()
	
	# Turn on
	turn_on()

# Return all enemies that can be reached based on the minimum attack and max attack
func get_reachable_enemies():
	# Array to Hold all
	reachable_enemies_list.clear()
	highlight_tiles.clear()
	
	# Queue
	var open_tile = []
	var attack_steps = selected_item.max_range
	open_tile.append([BattlefieldInfo.combat_player_unit.UnitMovementStats.currentTile, attack_steps])
	
	# Process all tiles
	while !open_tile.empty():
		# Pop first tile
		var tile_to_check = open_tile.pop_front()
		
		# Add tile to the highlight list
		if !highlight_tiles.has(tile_to_check[0]) \
		&& Calculators.get_distance_between_two_tiles(BattlefieldInfo.combat_player_unit.UnitMovementStats.currentTile, tile_to_check[0]) >= selected_item.min_range:
			highlight_tiles.append(tile_to_check[0])
		
		# Check if tile is occupied
		for adj_tile in tile_to_check[0].adjCells:
			var move_steps = tile_to_check[1] - 1
			if move_steps >= 0:
				# Is the tile actually within the min range?
				if Calculators.get_distance_between_two_tiles(BattlefieldInfo.combat_player_unit.UnitMovementStats.currentTile, adj_tile) >= selected_item.min_range:
					# Check if tile is occupied by enemy
					if adj_tile.occupyingUnit != null && !adj_tile.occupyingUnit.UnitMovementStats.is_ally:
						# Don't add twice
						if !reachable_enemies_list.has(adj_tile.occupyingUnit):
							reachable_enemies_list.append(adj_tile.occupyingUnit)
				open_tile.append([adj_tile, move_steps])

# Process Selection -> go to combat phase
func process_selection():
	# Turn this off
	turn_off()
	
	# Start combat phase
	get_parent().get_node("Combat Screen").start_combat(Combat_Screen.player_first_turn)

# Update preview boxes
func update_preview_box():
	# Update Selected Unit
	BattlefieldInfo.combat_ai_unit = current_option_selected
	
	# Calculate damage previews
	Combat_Calculator.calculate_damage()
	
	# Set menu position
	set_menu_position()
	
	# Player
	$"Preview/Player/Player Name".text = BattlefieldInfo.combat_player_unit.UnitStats.name
	$"Preview/Player/Player Item Icon".texture = selected_item.icon
	$"Preview/Player/Player HP".text = str(BattlefieldInfo.combat_player_unit.UnitStats.current_health)
	$"Preview/Player/Player Dmg".text = str(Combat_Calculator.player_damage)
	$"Preview/Player/Player Crit".text = str(Combat_Calculator.player_critical_rate)
	$"Preview/Player/Player Hit".text = str(Combat_Calculator.player_accuracy)
	
	# Enemy
	$"Preview/Enemy/Enemy Name".text = BattlefieldInfo.combat_ai_unit.UnitStats.name
	$"Preview/Enemy/Enemy Item Icon".texture = BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.icon
	$"Preview/Enemy/Enemy Item Name".text = BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.item_name
	$"Preview/Enemy/Enemy HP".text = str(BattlefieldInfo.combat_ai_unit.UnitStats.current_health)
	$"Preview/Enemy/Enemy Dmg".text = str(Combat_Calculator.enemy_damage)
	$"Preview/Enemy/Enemy Crit".text = str(Combat_Calculator.enemy_critical_rate)
	$"Preview/Enemy/Enemy Hit".text = str(Combat_Calculator.enemy_accuracy)

# Set position of menu -> This needs to be fixed later
func set_menu_position():
	if current_option_selected.get_node("Damage_Preview").overlaps_body(get_parent().get_node("GameCamera/Areas/TopLeft")) || \
		current_option_selected.get_node("Damage_Preview").overlaps_body(get_parent().get_node("GameCamera/Areas/BottomLeft")):
			$Preview.rect_position = LEFT_SIDE
	else:
		$Preview.rect_position = RIGHT_SIDE

# Update chosen enemy
func update_enemy_chosen():
	current_option_selected.get_node("Cursor Select").visible = false
	current_option_selected = reachable_enemies_list[current_number_selected]
	current_option_selected.get_node("Cursor Select").visible = true

# Go back to the previous screen
func go_back():
	turn_off()
	# Back to weapon selection
	get_parent().get_node("Weapon Select").start()

# Highlight tiles
func turn_on_red_tiles():
	for red_tile in highlight_tiles:
		red_tile.get_node("MovementRangeRect").turnOn("Red")

func turn_off_red_tiles():
	for red_tile in highlight_tiles:
		red_tile.get_node("MovementRangeRect").turnOff("Red")

# On/Off
func turn_on():
	$Preview.visible = true
	
	turn_on_red_tiles()
	
	$Timer.start(0)

func turn_off():
	$Preview.visible = false
	current_option_selected.get_node("Cursor Select").visible = false
	turn_off_red_tiles()
	is_active = false

func _on_Timer_timeout():
	is_active = true