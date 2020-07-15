extends CanvasLayer

# Reachable enemies
var reachable_allies_list = []
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
	$Preview.rect_position = RIGHT_SIDE
	
	get_parent().get_node("Action Selector Screen").connect("menu_moved", self, "set_menu_position")

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
			current_number_selected = reachable_allies_list.size() - 1
		$"Hand Selector/Move".play(0)
		update_enemy_chosen()
		update_preview_box()
	elif Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("ui_left"):
		current_number_selected += 1
		if current_number_selected >= reachable_allies_list.size():
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
	current_option_selected = reachable_allies_list[current_number_selected]
	
	# Update cursor
	update_enemy_chosen()
	
	# Update Box
	update_preview_box()
	
	# Turn on
	turn_on()

# Return all enemies that can be reached based on the minimum attack and max attack
func get_reachable_enemies():
	# Array to Hold all
	reachable_allies_list.clear()
	highlight_tiles.clear()
	
	# Queue
	var open_tile = []
	var attack_steps = selected_item.max_range
	open_tile.append([BattlefieldInfo.combat_player_unit.UnitMovementStats.currentTile, attack_steps])

	var weapon = selected_item
	# Check if we can reach that unit
	var queue = []
	#var max_range # Max range
	#var min_range # Min range
	queue.append([weapon.max_range, BattlefieldInfo.current_Unit_Selected.UnitMovementStats.currentTile])
	while !queue.empty():
		# Pop first tile
		var check_tile = queue.pop_front()
		
		# Check if the tile has someone If we do, we have an ally we can heal and reach Exit, we are done
		if check_tile[1].occupyingUnit != null && check_tile[1].occupyingUnit.UnitMovementStats.is_ally && check_tile[1].occupyingUnit != BattlefieldInfo.current_Unit_Selected:
			if Calculators.get_distance_between_two_tiles(check_tile[1], BattlefieldInfo.current_Unit_Selected.UnitMovementStats.currentTile) >= weapon.min_range:
				if !reachable_allies_list.has(check_tile[1].occupyingUnit) && check_tile[1].occupyingUnit.UnitStats.current_health < check_tile[1].occupyingUnit.UnitStats.max_health:
					reachable_allies_list.append(check_tile[1].occupyingUnit)
		
		# Tile was empty 
		for adjTile in check_tile[1].adjCells:
			var next_cost = check_tile[0] - 1
			
			if next_cost >= 0:
				queue.append([next_cost, adjTile])

# Process Selection -> go to combat phase
func process_selection():
	# Turn this off
	turn_off()
	
	# Start combat phase
	BattlefieldInfo.combat_screen.start_combat(Combat_Screen.player_healing)

# Update preview boxes
func update_preview_box():
	# Update Selected Unit
	BattlefieldInfo.combat_ai_unit = current_option_selected
	
	# Calculate damage previews
	Combat_Calculator.calculate_healing()
	
	# Player
	$"Preview/Player/Player Name".text = BattlefieldInfo.combat_player_unit.UnitStats.name
	$"Preview/Player/Player Item Icon".texture = selected_item.icon
	$"Preview/Player/Player HP".text = str(BattlefieldInfo.combat_player_unit.UnitStats.current_health)
	$"Preview/Player/Player Dmg".text = str(Combat_Calculator.player_healing_total)
	
	# Enemy
	$"Preview/Enemy/Enemy Name".text = BattlefieldInfo.combat_ai_unit.UnitStats.name
	$"Preview/Enemy/Enemy Item Icon".texture = BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.icon
	$"Preview/Enemy/Enemy Item Name".text = BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.item_name
	$"Preview/Enemy/Enemy HP".text = str(BattlefieldInfo.combat_ai_unit.UnitStats.current_health)


# Set position of menu -> This needs to be fixed later
# Need to find a better solution to this because this is kinda hacky and works like 85% of the time
func set_menu_position(new_position):
	if new_position == "left":
		$Preview.rect_position = LEFT_SIDE
	else:
		$Preview.rect_position = RIGHT_SIDE

# Update chosen enemy
func update_enemy_chosen():
	current_option_selected.get_node("Cursor Select").visible = false
	current_option_selected = reachable_allies_list[current_number_selected]
	current_option_selected.get_node("Cursor Select").visible = true

# Go back to the previous screen
func go_back():
	turn_off()
	# Back to weapon selection
	get_parent().get_node("Healing Select").start()

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
