extends "res://Scenes/Events/Event Base.gd"

class_name L2_Event_Part2
# Event Description:
# Enemies will chat then camera will pan back to original spot
# Steps:
# 1. Enemy dialogue
# 2. Attack nearest unit
# 3. Move camera back to Eirika
# Part Number: 2

# Dialogue between the characters
var dialogue = [
	"General Vezarius:\n\nAh, my dear Eirika.",
	"General Vezarius:\n\nYour father thought it would have been safe to send you to Castle Merceus.",
	"General Vezarius:\n\nThere is no escaping now!",
	"General Vezarius:\n\nI will have your head and anyone else who stands in my way!",
	"General Vezarius:\n\nFoward my men! Paint the land red with their blood!"
]

# Move these actors and combat
var Vezarius
var Dead_soldier

# Camera
var movement_camera

func _init():
	event_name = "Level 2 Event Enemies talk, camera moves, gameplay starts"
	event_part = "Part 2"

func start():
	# Find Vezarius
	for enemy in BattlefieldInfo.enemy_units:
		if enemy.UnitStats.name == "Vezarius":
			Vezarius = enemy
			break
	
	# Find Dead soldier
	for ally in BattlefieldInfo.ally_units:
		if ally.UnitStats.name == "Dead Soldier":
			Dead_soldier = ally
			Dead_soldier.UnitStats.name = "Ephraim Soldier"
			ally.UnitStats.name = "Ephraim Soldier"
			break
	
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "move_actor")
	
	# Movement System Connect
	BattlefieldInfo.movement_system_cinematic.connect("unit_finished_moving_cinema", self, "enable_combat")
	
	# Battle Screen Connect
	BattlefieldInfo.combat_screen.connect("combat_screen_done", self, "move_camera")
	
	# Stop other music
	BattlefieldInfo.music_player.get_node("Unfufilled").stop()
	BattlefieldInfo.music_player.get_node("AllyLevel").play(0)
	
	# Start Text
	BattlefieldInfo.message_system.set_position(Messaging_System.TOP)
	enable_text(dialogue)

# Move Camera back
func move_camera():
	# Change the 100% crit back down
	Vezarius.UnitStats.bonus_crit = 0
	Vezarius.UnitStats.bonus_hit = 0
	Vezarius.UnitStats.bonus_hit = 0
	
	# New Position
	var new_position_for_camera = Vector2(48,0)
	
	# Turn off allies except for a few
	for ally in BattlefieldInfo.ally_units:
		ally.visible = false
		if ally.UnitStats.name == "Move Me 1":
			ally.visible = true
		
		if ally.UnitStats.name == "Move Me 2":
			ally.visible = true
		
		if ally.UnitStats.name == "Seth":
			ally.visible = true
		
		if ally.UnitStats.name == "Eirika":
			ally.visible = true
	
	# Move Camera and Remove old camera
	BattlefieldInfo.main_game_camera.get_node("Tween").connect("tween_all_completed", self, "event_complete")
	BattlefieldInfo.main_game_camera.get_node("Tween").interpolate_property(BattlefieldInfo.main_game_camera, "position", BattlefieldInfo.main_game_camera.position, new_position_for_camera, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	BattlefieldInfo.main_game_camera.current = true
	BattlefieldInfo.main_game_camera.get_node("Tween").start()

func move_actor():
	# Build path to the enemy
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(Vezarius, BattlefieldInfo.grid[5][17], BattlefieldInfo.grid)
	
	# Add actor to list and move them
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(Vezarius)
	BattlefieldInfo.movement_system_cinematic.is_moving = true

# Enable combat -> need some type of combat cinematic next time
func enable_combat():
	BattlefieldInfo.combat_screen.cinematic_branch = true
	BattlefieldInfo.combat_ai_unit = Vezarius
	BattlefieldInfo.combat_player_unit = Dead_soldier
	BattlefieldInfo.start_ai_combat()
	BattlefieldInfo.turn_manager.turn = Turn_Manager.ENEMY_COMBAT_TURN
