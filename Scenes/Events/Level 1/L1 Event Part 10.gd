extends Event_Base

class_name L1_Event_Part_10

# Event Description:
# Seth + Eirika chat for a bit

var seth
var eirika

# Dialogue between the characters
var dialogue = [
	"Seth:\n\nYour highness, we have arrived.",
	"Eirika:\n\nThank you Seth.",
	"Seth:\n\nWith most of the army engaged with the Almaryans, this areas has largely been left on it's own.",
	"Seth:\n\nThere are reports of bandits that are pillaging the area with impunity.",
	"Eirika:\n\nLet's check in on the nearby villages.",
]

# Set Names for Debug
func _init():
	event_name = "Level 2 Seth gives order to the soldiers."
	event_part = "Part 0.5"

func start():
	# Cinema Connect
	BattlefieldInfo.movement_system_cinematic.connect("unit_finished_moving_cinema", self, "enable_text_no_array")
	
	# Set up allies
	for ally in BattlefieldInfo.ally_units:
		if ally.UnitStats.name == "Seth" || ally.UnitStats.name == "Eirika":
			if ally.UnitStats.name == "Seth":
				seth = ally
			if ally.UnitStats.name == "Eirika":
				eirika = ally
			ally.visible = true
		else:
			ally.visible = false
	
	for enemy in BattlefieldInfo.enemy_units:
		enemy.visible = false
	
	for enemy in BattlefieldInfo.enemy_units:
		if enemy.UnitStats.name == "Marcus":
			enemy.visible = true
	
	# Turn on
	BattlefieldInfo.battlefield_container.get_node("Anim").play("Fade")
	yield(BattlefieldInfo.battlefield_container.get_node("Anim"), "animation_finished")
	
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "move_camera")
	
	# Start Text
	BattlefieldInfo.message_system.set_position(Messaging_System.TOP)
	
	# Start Actor movement
	move_actor()

func enable_text_no_array():
	BattlefieldInfo.message_system.start(dialogue)

func move_actor():
	# Get path
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(eirika, BattlefieldInfo.grid[4][13], BattlefieldInfo.grid)
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(seth, BattlefieldInfo.grid[4][14], BattlefieldInfo.grid)
	
	# Remove current tile
	eirika.UnitMovementStats.currentTile.occupyingUnit = null
	seth.UnitMovementStats.currentTile.occupyingUnit = null
	
	# Add to movement queue
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(eirika)
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(seth)
	
	# Start movement
	BattlefieldInfo.movement_system_cinematic.is_moving = true

# Move Camera back
func move_camera():
	# New Position
	var new_position_for_camera = Vector2(0,0)
	
	# Move Camera and Remove old camera
	BattlefieldInfo.main_game_camera.get_node("Tween").connect("tween_all_completed", self, "event_complete")
	BattlefieldInfo.main_game_camera.get_node("Tween").interpolate_property(BattlefieldInfo.main_game_camera, "position", BattlefieldInfo.main_game_camera.position, new_position_for_camera, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	BattlefieldInfo.main_game_camera.current = true
	BattlefieldInfo.main_game_camera.get_node("Tween").start()