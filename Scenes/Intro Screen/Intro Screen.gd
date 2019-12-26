extends Control

# No text background
var no_text_background = preload("res://assets/intro screen/intro background no text.jpg")

var level1 = preload("res://Scenes/Battlefield/Battlefield.tscn")

enum {INTRO, GAME_SELECT, WAIT}
var current_state = INTRO

var options = ["New Game", "Load Game", "Options Screen"]
var current_option
var current_option_number = 0

func _ready():
	# Start music
	$"Intro Song".play(0)
	
	current_state = INTRO
	
	current_option = options[current_option_number]
	
	# Queue free this once the scene transition is done. Might want to keep this in the memory later if we want to return to the main menu
	SceneTransition.connect("scene_changed", self, "queue_free")

func _input(event):
	match current_state:
		INTRO:
			# Any key
			if event is InputEventKey and event.is_pressed():
				current_state = GAME_SELECT
				$"Intro Background".texture = no_text_background
				$Options.visible = true
		GAME_SELECT:
			if Input.is_action_just_pressed("ui_up"):
				current_option_number -= 1
				$"Options/Hand Selector".rect_position.y -= 18
				if current_option_number < 0:
					current_option_number = 0
					current_option = options[current_option_number]
					$"Options/Hand Selector".rect_position.y += 18
				current_option = options[current_option_number]
				$"Options/Hand Selector/Move".play(0)
			if Input.is_action_just_pressed("ui_down"):
				current_option_number += 1
				$"Options/Hand Selector".rect_position.y += 18
				if current_option_number > options.size() - 1:
					current_option_number = options.size() - 1
					current_option = options[current_option_number]
					$"Options/Hand Selector".rect_position.y -= 18
				current_option = options[current_option_number]
				$"Options/Hand Selector/Move".play(0)
			if Input.is_action_just_pressed("ui_accept"):
				$"Options/Hand Selector/Accept".play(0)
				process_selection()

func process_selection():
	set_process_input(false)
	SceneTransition.change_scene(level1, 1)