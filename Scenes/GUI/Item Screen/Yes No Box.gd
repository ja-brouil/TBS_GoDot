extends Control

export var is_active = false

const ACTION_SIZE_Y = 19

var item_selected
var current_options = ["Yes","No"]
var current_option_selected
var current_option_number = 0

func start(item):
	turn_on()
	
	item_selected = item
	
	current_option_number = 0
	current_option_selected = current_options[current_option_number]
	
	# Reset Hand position
	$"Hand Selector".rect_position = Vector2(-8,7)
	
	$Timer.start(0)

# Input for Hand movement
func _input(event):
	if !is_active:
		return
		
	if Input.is_action_just_pressed("ui_accept"):
		process_selection()
	elif Input.is_action_just_pressed("ui_cancel"):
		$"Hand Selector/Cancel".play(0)
		go_back()
	elif Input.is_action_just_pressed("ui_up"):
		movement("up")
	elif Input.is_action_just_pressed("ui_down"):
		movement("down")

func movement(direction):
	match direction:
		"up":
			current_option_number -= 1
			if current_option_number < 0:
				current_option_number = 0
			else:
				$"Hand Selector".rect_position.y -= ACTION_SIZE_Y
				$"Hand Selector/Move".play(0)
			current_option_selected = current_options[current_option_number]
		"down":
			current_option_number += 1
			if current_option_number > current_options.size() - 1:
				current_option_number = current_options.size() - 1
			else:
				$"Hand Selector".rect_position.y += ACTION_SIZE_Y
				$"Hand Selector/Move".play(0)
			current_option_selected = current_options[current_option_number]

func process_selection():
	match current_option_selected:
		"Yes":
			# Remove the item
			$"Hand Selector/Accept".play(0)
			BattlefieldInfo.current_Unit_Selected.UnitInventory.remove_item(item_selected)
			
			# Is the inventory empty now?
			if BattlefieldInfo.current_Unit_Selected.UnitInventory.inventory.empty():
				back_to_action_selector()
			else:
				# Back to item screen
				is_active = false
				visible = false
				
				# Turn off parent
				get_parent().turn_off()
				
				# Go back to item screen
				get_parent().get_parent().get_parent().start()
		"No":
			$"Hand Selector/Cancel".play(0)
			go_back()
			is_active = false

func back_to_action_selector():
	# Turn this off
	is_active = false
	visible = false
	
	# Go back and turn off the other one
	get_parent().turn_off()
	get_parent().get_parent().get_parent().go_back()

func go_back():
	is_active = false
	
	get_parent().get_node("Timer").start(0)
	
	visible = false

func turn_on():
	# Turn On
	visible = true

func _on_Timer_timeout():
	is_active = true
