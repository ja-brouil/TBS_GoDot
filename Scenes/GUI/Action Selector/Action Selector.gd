extends CanvasLayer

# Constants
const MARGIN_LEFT_OF_TOP = 3
const ACTION_SIZE_Y = 10

# Position
const TOP_LEFT = Vector2(12,20)
const TOP_RIGHT = Vector2(181,20)
const OFF_SIDE = Vector2(-100,-100)
var new_menu_position = Vector2(0,0)

# Hand
const HAND_OFF_SET = Vector2(-5,-1.5)

# Signals for changing UI screens
signal selected_wait
signal selected_back

# UI Active
var is_active = false

# Keep track of all the actions that we have currently
var current_actions = []
var current_number_action = 0
var current_option_selected = "Wait"

func _ready():
	# Connect to Cursor
	get_parent().get_node("GameCamera/Areas/BottomLeft").connect("body_entered", self, "left_side")
	get_parent().get_node("GameCamera/Areas/BottomRight").connect("body_entered", self, "right_side")
	get_parent().get_node("GameCamera/Areas/TopLeft").connect("body_entered", self, "left_side")
	get_parent().get_node("GameCamera/Areas/TopRight").connect("body_entered", self, "right_side")
	
	BattlefieldInfo.unit_movement_system.connect("action_selector_screen", self, "start")

# Start this screen
func start():
	# Show action menu
	$"Action Menu".visible = true
	
	# Get Menu items
	var menu_items = get_menu_items()
	
	# Build Menu
	build_menu(menu_items)
	
	# Start input acceptance
	$Timer.start(0)

# Input for Hand movement
func _input(event):
	if !is_active:
		return
		
	if Input.is_action_just_pressed("ui_accept"):
		$"Action Menu/Hand Selector/Accept".play(0)
		process_selection()
	elif Input.is_action_just_pressed("ui_cancel"):
		$"Action Menu/Hand Selector/Cancel".play(0)
		go_back()
	elif Input.is_action_just_pressed("ui_up"):
		movement("up")
	elif Input.is_action_just_pressed("ui_down"):
		movement("down")

func movement(direction):
	match direction:
		"up":
			current_number_action -= 1
			if current_number_action < 0:
				current_number_action = 0
			else:
				$"Action Menu/Hand Selector".rect_position.y -= ACTION_SIZE_Y - 1
				$"Action Menu/Hand Selector/Move".play(0)
			current_option_selected = current_actions[current_number_action]
		"down":
			current_number_action += 1
			if current_number_action > current_actions.size() - 1:
				current_number_action = current_actions.size() - 1
			else:
				$"Action Menu/Hand Selector".rect_position.y += ACTION_SIZE_Y - 1
				$"Action Menu/Hand Selector/Move".play(0)
			current_option_selected = current_actions[current_number_action]


# Build the menu based on how many options there are
func build_menu(menu_items):
	# Move old items
	for child_nodes in $"Action Menu".get_children():
		child_nodes.rect_position = OFF_SIDE
	current_actions.clear()
	
	# Sort the array alphabetically
	menu_items.sort()
	
	# Put the top Item first
	$"Action Menu/Top".rect_position = new_menu_position
	
#	Get each item and build the menu
	var last_item = $"Action Menu/Top"
	for menu_item in menu_items:
		get_node(str("Action Menu/",menu_item)).rect_position = Vector2($"Action Menu/Top".rect_position.x + MARGIN_LEFT_OF_TOP, last_item.rect_position.y + ACTION_SIZE_Y - 1)
		last_item = get_node(str("Action Menu/",menu_item))
		current_actions.append(menu_item)
	# Move bottom
	$"Action Menu/Bottom".rect_position = Vector2(last_item.rect_position.x, last_item.rect_position.y + ACTION_SIZE_Y - 1) 
	
	# Set the hand cursor to the first item in the list
	$"Action Menu/Hand Selector".rect_position = get_node(str("Action Menu/", current_actions[0])).rect_position + HAND_OFF_SET
	current_option_selected = current_actions[0]
	current_number_action = 0

# Build the menu items
func get_menu_items():
	var menu_items = []
	
	# Check which enemies and allies are around
	for adj_cell in BattlefieldInfo.current_Unit_Selected.UnitMovementStats.currentTile.adjCells:
		# Do we have a healing item?
		for player_item in BattlefieldInfo.current_Unit_Selected.UnitInventory.inventory:
			if player_item.item_class == Item.ITEM_CLASS.MAGIC && player_item.weapon_type == Item.WEAPON_TYPE.HEALING:
				# calculate based on each item if we can reach that person
				print("Have a healing item!")
				
				# Add heal option
				if !menu_items.has("Heal"):
					menu_items.append("Heal")
		
		# Attack items
		for player_item in BattlefieldInfo.current_Unit_Selected.UnitInventory.inventory:
			# This should be based on how far you can reach -> For now if we have an item | This null check should be moved up as an optimization
			if player_item != null:
				# Check here with the longest distance normally
				for adj_cell in BattlefieldInfo.current_Unit_Selected.UnitMovementStats.currentTile.adjCells:
					if adj_cell.occupyingUnit != null && !adj_cell.occupyingUnit.UnitMovementStats.is_ally:
						if !menu_items.has("Attack"):
							menu_items.append("Attack")
							break
	
	# Trade Option | Convoy
	for adj_cell in BattlefieldInfo.current_Unit_Selected.UnitMovementStats.currentTile.adjCells:
		if adj_cell.occupyingUnit != null && adj_cell.occupyingUnit.UnitMovementStats.is_ally:
			if !menu_items.has("Trade"):
				menu_items.append("Trade")
			# Check if next to Eirika
			if adj_cell.occupyingUnit.UnitStats.name == "Eirika":
				if !menu_items.has("Convoy"):
					menu_items.append("Convoy")
	
	# Are we Eirika?
	if BattlefieldInfo.current_Unit_Selected.UnitStats.name == "Eirika":
		if !menu_items.has("Convoy"):
			menu_items.append("Convoy")
	
	# Cell Visit -> Armory/Arena/Village
	if BattlefieldInfo.current_Unit_Selected.UnitMovementStats.currentTile.tileName == "Village" || \
	   BattlefieldInfo.current_Unit_Selected.UnitMovementStats.currentTile.tileName == "Arena" || \
	   BattlefieldInfo.current_Unit_Selected.UnitMovementStats.currentTile.tileName == "Village":
		if !menu_items.has("Visit"):
			menu_items.append("Visit")
	
	# Always add Item and wait
	menu_items.append("Item")
	menu_items.append("Wait")
	return menu_items

# Process Selection
func process_selection():
	match current_option_selected:
		"Attack":
			# Go to the other menu
			get_parent().get_node("Weapon Select").start()
			print("From Action Selector: Selected Attack! Go to the attack screen!")
			
			# Turn off
			hide_action_menu()
		"Convoy":
			print("From Action Selector: Selected Convoy! Go to the convoy screen!")
		"Healing":
			print("From Action Selector: Selected Healing! Go to the healing screen!")
		"Item":
			print("From Action Selector: Selected Item! Go to the item screen!")
		"Trade":
			print("From Action Selector: Selected Trade! Go to the trade screen!")
		"Visit":
			print("From Action Selector: Selected Visit! Go to the visit screen!")
		"Wait":
			# Turn this off
			hide_action_menu()
			
			# Set unit to done
			BattlefieldInfo.current_Unit_Selected.UnitActionStatus.set_current_action(Unit_Action_Status.DONE)
			BattlefieldInfo.current_Unit_Selected.turn_greyscale_on()
			BattlefieldInfo.current_Unit_Selected.get_node("Animation").current_animation = "Idle"
			emit_signal("selected_wait")
			
# Go back
func go_back():
	# Move Unit back
	BattlefieldInfo.current_Unit_Selected.position = BattlefieldInfo.previous_position
	Calculators.update_unit_tile_info(BattlefieldInfo.current_Unit_Selected, BattlefieldInfo.grid[BattlefieldInfo.previous_position.x / Cell.CELL_SIZE][BattlefieldInfo.previous_position.y / Cell.CELL_SIZE])
	
	# Move Camera
	get_parent().get_node("GameCamera").position = BattlefieldInfo.previous_camera_position
	
	# Set status and animation
	BattlefieldInfo.current_Unit_Selected.UnitActionStatus.set_current_action(Unit_Action_Status.MOVE)
	BattlefieldInfo.current_Unit_Selected.get_node("Animation").play("Idle")
	
	# Move Cursor
	get_parent().get_node("Cursor").position = BattlefieldInfo.previous_position
	
	# Set Cursor status
	get_parent().get_node("Cursor").enable_standard()
	
	# Hide menu
	hide_action_menu()

# Left
func left_side(body):
	new_menu_position = TOP_RIGHT

# Right
func right_side(body):
	new_menu_position = TOP_LEFT

# Move everything off and hide it
func hide_action_menu():
	$"Action Menu".visible = false
	
	# Move old items
	for child_nodes in $"Action Menu".get_children():
		child_nodes.rect_position = OFF_SIDE
	
	# Turn off active
	is_active = false

func _on_Timer_timeout():
	# Active Input
	is_active = true
