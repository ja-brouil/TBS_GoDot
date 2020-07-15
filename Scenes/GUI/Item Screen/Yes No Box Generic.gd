# Generic Version of the Yes No Box
extends Control

export var is_active = false

const ACTION_SIZE_Y = 19

var current_options = ["Yes","No"]
var current_option_selected
var current_option_number = 0

# Signals
signal option_selected
signal no_inputted

func start():
	turn_on()
	
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
		emit_signal("option_selected", false)
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
			# $"Hand Selector/Accept".play(0)
			exit()
			emit_signal("option_selected", true)
			
		"No":
			# $"Hand Selector/Cancel".play(0)
			exit()
			emit_signal("option_selected", false)
			

func go_back():
	emit_signal("no_inputted")
	is_active = false
	visible = false

func exit():
	is_active = false
	visible = false

func turn_on():
	visible = true

func _on_Timer_timeout():
	is_active = true
