extends CanvasLayer

# To do later just write down what's needed to be done

# Constants 
const OFF_SET = Vector2(10,10)
const X_OFF_SET = Vector2(6,0)
const OFF_SCREEN = Vector2(-150, -150)
const HAND_POSITION = Vector2(5,18)
const SLOT_Y = Vector2(0,10)

# Input
var is_active = false

# Inventory
var usable_weapons = []

# List
var item_list_menu = []
var current_selected_number = 0
var current_selected_option = null

# Called when this UI comes into play
func start():
	# Get usable items first
	get_all_enemies_available()
	
	# Build menu
	build_item_list()
	
	# Place unit mugshot
	create_mugshot()
	
	# Update item
	update_item_box()
	
	# Start
	turn_on()

# Process input
func _input(event):
	if !is_active:
		return
	if Input.is_action_just_pressed("ui_up"):
		movement("up")
	elif Input.is_action_just_pressed("ui_down"):
		movement("down")
	elif Input.is_action_just_pressed("ui_accept"):
		$"Hand Selector/Accept".play(0)
		process_selection()
	elif Input.is_action_just_pressed("ui_cancel"):
		$"Hand Selector/Cancel".play(0)
		go_back()

# Get enemies available with weapons available
func get_all_enemies_available():
	pass

# Build Item List -> modify later with usable items
func build_item_list():
	# Clear old menu
	item_list_menu.clear()
	
	# Place Top
	$"Weapon Select/Weapon List/Top".rect_position = OFF_SET
	
	var last_position = OFF_SET + X_OFF_SET
	# Build item slot
	for weapon in BattlefieldInfo.current_Unit_Selected.UnitInventory.inventory:
		if weapon.item_class == Item.ITEM_CLASS.PHYSICAL || weapon.item_class == Item.ITEM_CLASS.MAGICAL:
			if weapon.weapon_type != Item.WEAPON_TYPE.HEALING:
				# Create a slot
				var item_slot = preload("res://Scenes/GUI/Weapon Select/Weapon Select Slot.tscn").instance() 
				
				# Fill data
				item_slot.start(weapon)
				
				# Place position and add child
				item_slot.rect_position = last_position + SLOT_Y - Vector2(0,1)
				$"Weapon Select/Weapon List".add_child(item_slot)
				
				# New previous position
				last_position = item_slot.rect_position
				
				# Add to array so we can queue free later
				item_list_menu.append(weapon)
	
	# Add Bottom
	$"Weapon Select/Weapon List/Bottom".rect_position = last_position + SLOT_Y
	
	# Place hand
	$"Hand Selector".rect_position = HAND_POSITION

# Place mugshot
func create_mugshot():
	$"Weapon Select/Unit Mugshot".texture = BattlefieldInfo.current_Unit_Selected.unit_mugshot

# Process movement
func movement(direction):
	match direction:
		"up":
			current_selected_number -= 1
			if current_selected_number < 0:
				current_selected_number = 0
			else:
				$"Hand Selector".rect_position.y -= SLOT_Y.y - 1
				$"Hand Selector/Move".play(0)
			current_selected_option = item_list_menu[current_selected_number]
		"down":
			current_selected_number += 1
			if current_selected_number >item_list_menu.size() - 1:
				current_selected_number = item_list_menu.size() - 1
			else:
				$"Hand Selector".rect_position.y += SLOT_Y.y - 1
				$"Hand Selector/Move".play(0)
			current_selected_option = item_list_menu[current_selected_number]
	update_item_box()

# Change the item box window whenever the cursor moves
func update_item_box():
	# Set selected item
	current_selected_option = item_list_menu[current_selected_number]
	
	# Set the box to the item
	$"Weapon Select/Item Box/Atk N".text = str(current_selected_option.might)
	$"Weapon Select/Item Box/Crit N".text = str(current_selected_option.crit)
	$"Weapon Select/Item Box/Avoid N".text = str(current_selected_option.weight)
	$"Weapon Select/Item Box/Hit N".text = str(current_selected_option.hit)
	$"Weapon Select/Item Box/Weapon Icon".texture = current_selected_option.icon
	$"Weapon Select/Item Box/Weapon".text = current_selected_option.item_name

# Cancel option
func go_back():
	# Turn off and go back to action selector
	turn_off()
	
	# Go back to action selector
	BattlefieldInfo.unit_movement_system.emit_signal("action_selector_screen")

# Go to unit selection
func process_selection():
	# Turn this off
	turn_off()
	
	# Set Current equipped item
	BattlefieldInfo.current_Unit_Selected.UnitInventory.current_item_equipped = current_selected_option
	
	# Go to the Damage preview screen
	get_parent().get_node("Damage Preview").start(current_selected_option)

# On/Off
func turn_on():
	# Activate Visibility
	$"Weapon Select".visible = true
	
	$"Hand Selector".visible = true
	
	# Reset option
	current_selected_number = 0
	
	# Start Input
	$Timer.start(0)

func turn_off():
	for item_slot in get_tree().get_nodes_in_group(GroupNames.ITEM_SLOT_GROUP_NAME):
		item_slot.queue_free()
	
	$"Weapon Select".visible = false
	is_active = false
	
	$"Hand Selector".visible = false
	
	# Reset option
	current_selected_number = 0

func _on_Timer_timeout():
	is_active = true