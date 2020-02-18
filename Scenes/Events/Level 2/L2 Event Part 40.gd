extends "res://Scenes/Events/Event Base.gd"

class_name L2_Event_Part4
# Event Description:
# Camera pans back to original location, all allies are now visible, Eirika and Seth have a few last words and then into combat we go
# Steps:
# 1. Camera pans back to original location
# 2. Dialogue
# 3. Move Units into the castle
# 4. Gameplay
# Part Number: 3

# Dialogue between the characters
var dialogue = [
	"Seth@assets/units/cavalier/seth mugshot.png@Your highness, please head inside! I cannot guarantee your safety out here.",
	"Eirika@assets/units/eirika/eirika mugshot.png@No Seth! My place is here among my people here! I will fight alongside them!",
	"Seth@assets/units/cavalier/seth mugshot.png@Very well my lady.",
	"Eirika@assets/units/eirika/eirika mugshot.png@Let's go everyone! I am by your side! Let us fight together!"
]

# Actors to move
var ewan
var natasha
var neimi
var gilliam
var vanessa
var colm

func _init():
	event_name = "Level 2 Before Battle Event"
	event_part = "Part 3"

func start():
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "move_actors")
	
	# Register to the movement
	BattlefieldInfo.movement_system_cinematic.connect("unit_finished_moving_cinema", self, "move_camera")
	
	# Show allies
	ewan = BattlefieldInfo.ally_units["Ewan"]
	natasha = BattlefieldInfo.ally_units["Natasha"]
	neimi = BattlefieldInfo.ally_units["Neimi"]
	gilliam = BattlefieldInfo.ally_units["Gilliam"]
	vanessa = BattlefieldInfo.ally_units["Vanessa"]
	colm = BattlefieldInfo.ally_units["Colm"]
	
	# Start Text
	enable_text(dialogue)

func move_actors():
	for ally in BattlefieldInfo.ally_units.values():
		ally.visible = true
	
	# Build path to the location
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(natasha, BattlefieldInfo.grid[8][5], BattlefieldInfo.grid)
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(ewan, BattlefieldInfo.grid[10][5], BattlefieldInfo.grid)
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(neimi, BattlefieldInfo.grid[7][6], BattlefieldInfo.grid)
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(gilliam, BattlefieldInfo.grid[8][8], BattlefieldInfo.grid)
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(vanessa, BattlefieldInfo.grid[11][6], BattlefieldInfo.grid)
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(colm, BattlefieldInfo.grid[11][4], BattlefieldInfo.grid)
	
	# Remove original tile
	natasha.UnitMovementStats.currentTile.occupyingUnit = null
	ewan.UnitMovementStats.currentTile.occupyingUnit = null
	neimi.UnitMovementStats.currentTile.occupyingUnit = null
	gilliam.UnitMovementStats.currentTile.occupyingUnit = null
	vanessa.UnitMovementStats.currentTile.occupyingUnit = null
	colm.UnitMovementStats.currentTile.occupyingUnit = null
	
	# Add actors to movement
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(natasha)
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(neimi)
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(ewan)
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(gilliam)
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(vanessa)
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(colm)
	
	# Start the cinematic movement
	BattlefieldInfo.movement_system_cinematic.is_moving = true

func move_camera():
	# New Position
	var new_position_for_camera = Vector2(0,190)
	
	# Move Camera
	BattlefieldInfo.main_game_camera.get_node("Tween").connect("tween_all_completed", self, "event_complete")
	BattlefieldInfo.main_game_camera.get_node("Tween").interpolate_property(BattlefieldInfo.main_game_camera, "position", BattlefieldInfo.main_game_camera.position, new_position_for_camera, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	BattlefieldInfo.main_game_camera.get_node("Tween").start()
