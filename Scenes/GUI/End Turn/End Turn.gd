extends CanvasLayer

# Activate bool
var is_active = false

# Options
var menu_items = ["Unit", "Status", "Suspend", "End"]
var current_number_action = 0 
var current_option_selected = menu_items[0]

# Hand Movement
const ACTION_SIZE_Y = 10
const original_hand_place = Vector2(15,40)

func _ready():
	pass

# Handle input
func _input(event):
	if !is_active:
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		$"End Turn/Hand Selector/Accept".play(0)
		process_selection()
	elif Input.is_action_just_pressed("ui_cancel"):
		$"End Turn/Hand Selector/Cancel".play(0)
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
				$"End Turn/Hand Selector".rect_position.y -= ACTION_SIZE_Y - 1
				$"End Turn/Hand Selector/Move".play(0)
			current_option_selected = menu_items[current_number_action]
		"down":
			current_number_action += 1
			if current_number_action > menu_items.size() - 1:
				current_number_action = menu_items.size() - 1
			else:
				$"End Turn/Hand Selector".rect_position.y += ACTION_SIZE_Y - 1
				$"End Turn/Hand Selector/Move".play(0)
			current_option_selected = menu_items[current_number_action]

# Handle selection
func process_selection():
	match current_option_selected:
		"Unit":
			print("FROM END TURN: Units status selected")
		"Status":
			print("FROM END TURN: Show map/unit status")
		"Suspend":
			print("FROM END TURN: Suspend")
		"End":
			# Get all ally units and put it to end
			for ally_unit in BattlefieldInfo.ally_units:
				ally_unit.UnitActionStatus.set_current_action(Unit_Action_Status.DONE)
				ally_unit.get_node("Animation").current_animation = "Idle"
			
			# Turn this off
			turn_off()
			
			# Transition
			BattlefieldInfo.turn_manager.emit_signal("check_end_turn")

# Cancel
func go_back():
	# Enable the cursor again
	get_parent().get_node("Cursor").back_to_move()
	get_parent().get_node("Cursor").emit_signal("turn_on_ui")
	
	# turn this off
	turn_off()

# Start function
func start():
	# Activate
	turn_on()
	
	# Reset hand
	current_number_action = 0
	current_option_selected = menu_items[current_number_action]
	$"End Turn/Hand Selector".rect_position = original_hand_place
	
	# Turn cursor off
	get_parent().get_node("Cursor").enable(false, Cursor.WAIT)

# Turn on or off
func turn_on():
	is_active = true
	$"End Turn".visible = true

func turn_off():
	is_active = false
	$"End Turn".visible = false