extends Control

# Change the various game settings here
# Current controls
# Keyboard mappings

# Current UI node that we have selected
var all_node_settings = []
var current_setting_index = 0
var current_setting_selected = null

# Key Timer
const INCREMENT_SPEED = 10
var step_increment = 0
var key_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Start the music
	$"Settings Music".play(0)
	
	# Load the array
	all_node_settings.append($"Sound Settings/Music Volume")
	all_node_settings.append($"Sound Settings/Sound Volume")
	

func start():
	pass

func exit():
	pass

# Key press check
func _process(delta):
	if Input.is_key_pressed(KEY_LEFT) || Input.is_key_pressed(KEY_RIGHT):
		key_timer += delta
		if key_timer > 2:
			step_increment = clamp(step_increment + (INCREMENT_SPEED * delta), 0, 5)
	else:
		key_timer = 0
		step_increment = 0


func _input(event):
	if Input.is_action_pressed("ui_left"):
		all_node_settings[current_setting_index].value -= all_node_settings[current_setting_index].step + step_increment
		all_node_settings[current_setting_index].update()
		update_settings()
	elif Input.is_action_pressed("ui_right"):
		all_node_settings[current_setting_index].value += all_node_settings[current_setting_index].step + step_increment
		all_node_settings[current_setting_index].update()
		update_settings()
	elif Input.is_action_just_pressed("ui_up"):
		current_setting_index -= 1
		if current_setting_index < 0:
			current_setting_index = all_node_settings.size() - 1
	elif Input.is_action_just_pressed("ui_down"):
		current_setting_index += 1
		if current_setting_index > all_node_settings.size() - 1:
			current_setting_index = 0

func update_settings():
	match current_setting_index:
		# Music
		0:
			$"Sound Settings/Music Volume/Volume Level".text = str(all_node_settings[current_setting_index].value)
			AudioServer.set_bus_volume_db(0, ((100 - all_node_settings[current_setting_index].value) / 2) * -1)
		# Sound
		1:
			$"Sound Settings/Sound Volume/Volume Level".text = str(all_node_settings[current_setting_index].value)
	print(AudioServer.get_bus_volume_db(0))

# 6.6 = 100
# 70 = 0
func get_new_volume(value):
	return 0

# Factory reset all settings back to default
func reset_settings_to_default():
	pass

# Call this function when we need to reset the settings
func reset():
	pass

# Save and load function
func save():
	pass

func load_settings():
	pass
