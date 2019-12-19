extends Event_Base

class_name L2_Event_Mid_10

# Move Vez back to original position and start spawning reinforcements

signal actors_spawned

var dialogue = [
		"Vezarius:\n\nHmph, I didn't expect them to put up this much of a fight.",
		"Vezarius:\n\nHahahahaha. Wonderful!",
		"Vezarius:\n\nCall in the reinforcements!"
]

# Actors
var vez
var new_enemies = []

func start():
	for enemy in BattlefieldInfo.enemy_units:
		if enemy.UnitStats.name == "Vezarius":
			vez = enemy
	
	# Signals needed
	BattlefieldInfo.movement_system_cinematic.connect("individual_unit_finished_moving", self, "start_dialogue")
	BattlefieldInfo.message_system.connect("no_more_text", self, "spawn_enemies")
	BattlefieldInfo.main_game_camera.get_node("Tween").connect("tween_all_completed", self, "move_actor")

func move_camera():
	var new_position_for_camera = Vector2(48,0)
	BattlefieldInfo.main_game_camera.get_node("Tween").interpolate_property(BattlefieldInfo.main_game_camera, "position", BattlefieldInfo.main_game_camera.position, new_position_for_camera, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	BattlefieldInfo.main_game_camera.current = true
	BattlefieldInfo.main_game_camera.get_node("Tween").start()

func move_actor():
	# Build path to Vezarius Original Location
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(vez, BattlefieldInfo.grid[0][272 / 16], BattlefieldInfo.grid)
	
	# Remove original tile
	vez.UnitMovementStats.currentTile.occupyingUnit = null
	
	# Move Actor
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(vez)
	BattlefieldInfo.movement_system_cinematic.is_moving = true

func move_actor_2():
	pass

func start_dialogue():
	BattlefieldInfo.message_system.set_position(Messaging_System.TOP)
	enable_text(dialogue)

# Spawn a bunch of new enemies then move them
func spawn_enemies():
	# Disconnect the old signal
	BattlefieldInfo.movement_system_cinematic.disconnect("individual_unit_finished_moving", self, "start_dialogue")
	
	# Spawn a bunch of new enemies
	for spawn_point in BattlefieldInfo.