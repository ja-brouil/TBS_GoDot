extends Event_Base

class_name L2_Event_Mid_20

# Get Vez out of the map
signal messenger_spawned

var dialogue = [
		"Diagur@assets/units/enemyPortrait/Diagur Portrait.png@General Vezarius!",
		"Vezarius@assets/units/enemyPortrait/Main Villain MugShot.png@Ah Diagur. I was wondering when you would show up.",
		"Diagur@assets/units/enemyPortrait/Diagur Portrait.png@I have an important message for you. You are needed back at the base camp.",
		"Vezarius@assets/units/enemyPortrait/Main Villain MugShot.png@What! I just started here.",
		"Diagur@assets/units/enemyPortrait/Diagur Portrait.png@I come here with a direct order from the Emperor. I am to take over this operation.",
		"Diagur@assets/units/enemyPortrait/Diagur Portrait.png@His Majesty has requested your presence immediately. You are needed for the next phase of the plan.",
		"Vezarius@assets/units/enemyPortrait/Main Villain MugShot.png@Hmm...",
		"Vezarius@assets/units/enemyPortrait/Main Villain MugShot.png@Very well... I take my leave and leave this to you.",
		"Vezarius@assets/units/enemyPortrait/Main Villain MugShot.png@You better not fail his majesty. You know what comes to those who fail their orders.",
		"Diagur@assets/units/enemyPortrait/Diagur Portrait.png@I will succeed in capturing our troublesome princess!",
		"Diagur@assets/units/enemyPortrait/Diagur Portrait.png@Now get out of here.",
		"Diagur@assets/units/enemyPortrait/Diagur Portrait.png@Come forth my men! Bring me Eirika's head!"
]

# Actors
var vez
var id_number = 199

func _init():
	# Get General vez
	vez = BattlefieldInfo.enemy_units["Vezarius"]
	
	# Register to the turn numbers
	BattlefieldInfo.turn_manager.connect("enemy_turn_increased", self, "start_mid")
	BattlefieldInfo.turn_manager.connect("player_turn_increased", self, "play_player_transition")
	
	path = "res://Scenes/Events/Level 2/L2 Event Mid 20.gd"

func play_player_transition(turn_number):
	BattlefieldInfo.turn_manager.start_ally_transition()

func start_mid(turn_number):
	# Do not process if turn is not 2
	if turn_number <= 4:
		return
	
	if turn_number != 7:
		BattlefieldInfo.turn_manager.start_enemy_transition()
		return
	
	# Turn off UI/Input
	BattlefieldInfo.event_system.pause_ui()
	
	# Signals needed
	BattlefieldInfo.movement_system_cinematic.connect("unit_finished_moving_cinema", self, "start_dialogue")
	BattlefieldInfo.message_system.connect("no_more_text", self, "spawn_enemies")
	BattlefieldInfo.main_game_camera.get_node("Tween").connect("tween_all_completed", self, "move_actor")
	
	spawn_messenger()
	move_camera()

func move_camera():
	var new_position_for_camera = Vector2(0,190)
	BattlefieldInfo.main_game_camera.get_node("Tween").interpolate_property(BattlefieldInfo.main_game_camera, "position", BattlefieldInfo.main_game_camera.position, new_position_for_camera, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	BattlefieldInfo.main_game_camera.current = true
	BattlefieldInfo.main_game_camera.get_node("Tween").start()

func move_actor():
	# Build path to Vezarius Original Location
	if vez.UnitMovementStats.currentTile != BattlefieldInfo.grid[0][272 / 16]:
		BattlefieldInfo.movement_calculator.get_path_to_destination_AI(vez, BattlefieldInfo.grid[0][272 / 16], BattlefieldInfo.grid)
		BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(vez)
		vez.UnitMovementStats.currentTile.occupyingUnit = null
	
	# Move Messenger
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(BattlefieldInfo.enemy_units["Remove Me"], BattlefieldInfo.grid[0][256 / 16], BattlefieldInfo.grid)
	BattlefieldInfo.enemy_units["Remove Me"].UnitMovementStats.currentTile.occupyingUnit = null
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(BattlefieldInfo.enemy_units["Remove Me"])
	
	BattlefieldInfo.movement_system_cinematic.is_moving = true

func start_dialogue():
	BattlefieldInfo.message_system.set_position(Messaging_System.BOTTOM)
	enable_text(dialogue)

# Func spawn messenger
func spawn_messenger():
	var messenger = preload("res://Scenes/Units/Enemy_Units/Enemy Pegasus Knight.tscn")
	
	var newEnemy = messenger.instance()
	newEnemy.get_node("AI").ai_type = "Passive"
	BattlefieldInfo.current_level.get_node("YSort").add_child(newEnemy)
	
	# Set Stats and position
	newEnemy.position = Vector2(0,160)
	newEnemy.UnitStats.name = "Diagur"
	newEnemy.UnitStats.strength = 5 + Calculators.get_random_number(0,2)
	newEnemy.UnitStats.skill = 3 + Calculators.get_random_number(0,2)
	newEnemy.UnitStats.speed = 2 + Calculators.get_random_number(0,2)
	newEnemy.UnitStats.magic = 0
	newEnemy.UnitStats.luck = 0 + Calculators.get_random_number(0,2)
	newEnemy.UnitStats.def = 1 + Calculators.get_random_number(0,2) 
	newEnemy.UnitStats.res = 0 + Calculators.get_random_number(0,2)
	newEnemy.UnitStats.consti = 8
	newEnemy.UnitStats.bonus_crit = 0
	newEnemy.UnitStats.bonus_dodge = 0
	newEnemy.UnitStats.bonus_hit = 0
	newEnemy.UnitStats.level = 3 + Calculators.get_random_number(0,2)
	newEnemy.UnitStats.class_type = "Pegasus Knight"
	newEnemy.UnitStats.current_health = 21  + Calculators.get_random_number(0,2)
	newEnemy.UnitStats.max_health = newEnemy.UnitStats.current_health
	
	# XP Stats
	newEnemy.UnitStats.class_power = 3
	newEnemy.UnitStats.class_bonus_a = 0
	newEnemy.UnitStats.class_bonus_b = 0
	newEnemy.UnitStats.boss_bonus = 0
	newEnemy.UnitStats.thief_bonus = 0
	
	# New Portrait
	newEnemy.unit_portrait_path = load("res://assets/units/enemyPortrait/Diagur Portrait.png")
	
	# Set the current tile
	newEnemy.UnitMovementStats.currentTile = BattlefieldInfo.grid[0][224 / 16]
	BattlefieldInfo.grid[0][224 / 16].occupyingUnit = newEnemy
	
	# Set Sentences
	newEnemy.death_sentence = ["Diagur:\n\nHow...did I lose... to these rats...?"]
	
	# Before battle sentence
	newEnemy.before_battle_sentence = ["Diagur:\n\nTaste the spear of the Empire!"]
	
	# Add Unit to the list of enemies
	newEnemy.UnitMovementStats.is_ally = false
	id_number += 1
	newEnemy.UnitStats.identifier = str("Remove Me")
	BattlefieldInfo.enemy_units["Remove Me"] = newEnemy

# Spawn a bunch of new enemies then move them
func spawn_enemies():
	# Enemy list
	var e_soldier = preload("res://Scenes/Units/Enemy_Units/Enemy Soldier.tscn")
	var a_soldier = preload("res://Scenes/Units/Enemy_Units/Black Archer.tscn")
	var b_soldier = preload("res://Scenes/Units/Enemy_Units/Bandit.tscn")
	var p_solider = preload("res://Scenes/Units/Enemy_Units/Enemy Pegasus Knight.tscn")
	
	# Spawn a bunch of new enemies
	for spawn_point in BattlefieldInfo.spawn_points:
		var random_unit = Calculators.get_random_number(0,3)
		var newEnemy
		
		# Spawn random new enemy based on the number that was randomly generated
		match random_unit:
			0:
				newEnemy = e_soldier.instance()
			1:
				newEnemy = a_soldier.instance()
			2:
				newEnemy = b_soldier.instance()
			3:
				newEnemy = p_solider.instance()
		
		for adjCell in spawn_point.adjCells:
			if adjCell.occupyingUnit == null:
				newEnemy.get_node("AI").ai_type = "Aggresive"
				BattlefieldInfo.current_level.get_node("YSort").add_child(newEnemy)
				
				# Set Stats and position
				newEnemy.position = adjCell.position
				newEnemy.UnitStats.name = "Soldier"
				newEnemy.UnitStats.strength = 5 + Calculators.get_random_number(0,2)
				newEnemy.UnitStats.skill = 3 + Calculators.get_random_number(0,2)
				newEnemy.UnitStats.speed = 2 + Calculators.get_random_number(0,2)
				newEnemy.UnitStats.magic = 0
				newEnemy.UnitStats.luck = 0 + Calculators.get_random_number(0,2)
				newEnemy.UnitStats.def = 1 + Calculators.get_random_number(0,2) 
				newEnemy.UnitStats.res = 0 + Calculators.get_random_number(0,2)
				newEnemy.UnitStats.consti = 8
				newEnemy.UnitStats.bonus_crit = 0
				newEnemy.UnitStats.bonus_dodge = 0
				newEnemy.UnitStats.bonus_hit = 0
				newEnemy.UnitStats.level = 3 + Calculators.get_random_number(0,2)
				newEnemy.UnitStats.class_type = "Soldier"
				newEnemy.UnitStats.current_health = 21  + Calculators.get_random_number(0,2)
				newEnemy.UnitStats.max_health = newEnemy.UnitStats.current_health
				
				
				# XP Stats
				newEnemy.UnitStats.class_power = 3
				newEnemy.UnitStats.class_bonus_a = 0
				newEnemy.UnitStats.class_bonus_b = 0
				newEnemy.UnitStats.boss_bonus = 0
				newEnemy.UnitStats.thief_bonus = 0
				
				# Set the current tile
				newEnemy.UnitMovementStats.currentTile = adjCell
				adjCell.occupyingUnit = newEnemy
				
				# Add Unit to the list of enemies
				newEnemy.UnitMovementStats.is_ally = false
				id_number += 1
				newEnemy.UnitStats.identifier = str("Enemy ",id_number)
				BattlefieldInfo.enemy_units[str("Enemy ",id_number)] = newEnemy
	
	# Remove the enemies
	BattlefieldInfo.enemy_units["Vezarius"].UnitMovementStats.currentTile.occupyingUnit = null
	BattlefieldInfo.enemy_units["Vezarius"].free()
	BattlefieldInfo.enemy_units.erase("Vezarius")
	
	# Set new Commander
	BattlefieldInfo.enemy_commander = BattlefieldInfo.enemy_units["Remove Me"]
	BattlefieldInfo.level_container.enemy_commander_name = "Remove Me"
	
	# Clear
	BattlefieldInfo.current_Unit_Selected = null
	
	# Set new objective
#	StatusScreen.set_screen_objective_desc("Kill all Enemies")
#	BattlefieldInfo.victory_text = "Kill all Enemies"
#	BattlefieldInfo.victory_system.victory_condition_state = Victory_Checker.ELIMINATE_ALL_ENEMIES
	
	# Remove this from the array
	BattlefieldInfo.event_system.mid_level_events.erase(self)
	BattlefieldInfo.turn_manager.start_enemy_transition()
	queue_free()
