# Represents all the units in the game
extends Node2D

class_name Battlefield_Unit

# Graphics
export(String) var sprite_dir = "Idle"
export(int) var animation_movement_speed = 10

# Movement -> Ally status is in here
var UnitMovementStats
var animation_movement

# Unit State
var UnitActionStatus

# Unit Stats
var UnitStats

# Inventory
var UnitInventory

# Unit portrait
var unit_portrait_path

# Unit Mugshot
var unit_mugshot

# Combat sprites
var combat_node

# Death sentence for allies and enemies
var death_sentence

# Before battle sentence
var before_battle_sentence = null

func _ready():
	# Movement Stats
	UnitMovementStats = Unit_Movement.new()
	UnitMovementStats.name = "UnitMovementStats"
	add_child(UnitMovementStats, true)

	# Unit Action state
	UnitActionStatus = Unit_Action_Status.new()
	UnitActionStatus.name = "UnitActionStatus"
	add_child(UnitActionStatus, true)
	
	# Inventory
	UnitInventory = preload("res://Scenes/Units/Unit_Scripts/Inventory.tscn").instance()
	add_child(UnitInventory)
	
	# Unit stats
	UnitStats = Unit_Stats.new()

# Greyscale options
func turn_greyscale_on():
	get_node("Sprite").modulate = Color(0.33, 0.34, 0.37, 1)

func turn_greyscale_off():
	get_node("Sprite").modulate = Color(1, 1, 1, 1)

# Get Direction to face
# Returns the direction that the unit should be facing
func get_direction_to_face(starting_cell, destination_cell) -> String:
	# Right
	if starting_cell.getPosition().x - destination_cell.getPosition().x < 0 && starting_cell.getPosition().y - destination_cell.getPosition().y == 0:
		return "Right"
	# Left
	elif starting_cell.getPosition().x - destination_cell.getPosition().x > 0 && starting_cell.getPosition().y - destination_cell.getPosition().y == 0: 
		return "Left"
	# North
	elif starting_cell.getPosition().x - destination_cell.getPosition().x == 0 && starting_cell.getPosition().y - destination_cell.getPosition().y > 0:
		return "Up"
	# South
	elif starting_cell.getPosition().x - destination_cell.getPosition().x == 0 && starting_cell.getPosition().y - destination_cell.getPosition().y < 0:
		return "Down"
	# Fail safe
	else:
		return "Idle"

# Save the unit
func save():
	var save_dict = {
		# File and parent
		"node_info" : {
			"filename" : get_filename(),
			"parent": get_parent().get_path(),
		},
		
		# Position
		"vector2" : {
			"pos_x": position.x,
			"pos_y": position.y,
		},
		
		# Unit Movement Stats
		"unit_movement_stats": {
			"movementSteps" : UnitMovementStats.movementSteps,
			"is_ally" : UnitMovementStats.is_ally,
			"defaultPenalty" : UnitMovementStats.defaultPenalty,
			"mountainPenalty" : UnitMovementStats.mountainPenalty,
			"hillPenalty" : UnitMovementStats.hillPenalty,
			"forestPenalty" : UnitMovementStats.forestPenalty,
			"fortressPenalty" : UnitMovementStats.fortressPenalty,
			"buildingPenalty" : UnitMovementStats.buildingPenalty,
			"riverPenalty" : UnitMovementStats.riverPenalty,
			"sea_penalty" : UnitMovementStats.seaPenalty,
		},
		
		# Action Status
		"action_status": {
			"current_action_status": UnitActionStatus.current_action_status,
		},
		
		# Unit Stats
		"unit_stats" : {
			"identifier": UnitStats.identifier,
			"name": UnitStats.name,
			"level" : UnitStats.level,
			"current_xp" : UnitStats.current_xp,
			"skill" : UnitStats.skill,
			"current_health": UnitStats.current_health,
			"max_health": UnitStats.max_health,
			"pegasus": UnitStats.pegasus,
			"bonus_crit" : UnitStats.bonus_crit,
			"luck": UnitStats.luck,
			"class_bonus_b": UnitStats.class_bonus_b,
			"class_bonus_a": UnitStats.class_bonus_a,
			"class_power": UnitStats.class_power,
			"class_type": UnitStats.class_type,
			"str_chance" : UnitStats.str_chance,
			"skill_chance" : UnitStats.skill_chance,
			"speed_chance" : UnitStats.speed_chance,
			"magic_chance" : UnitStats.magic_chance,
			"luck_chance" : UnitStats.luck_chance,
			"def_chance" : UnitStats.def_chance,
			"res_chance" : UnitStats.res_chance,
			"consti_chance" : UnitStats.consti_chance,
			"max_health_chance": UnitStats.max_health_chance,
			"horse": UnitStats.horse,
			"armor" : UnitStats.armor,
			"speed": UnitStats.speed,
			"strength": UnitStats.strength,
			"def": UnitStats.def,
			"magic" : UnitStats.magic,
			"consti" : UnitStats.consti,
			"bonus_hit": UnitStats.bonus_hit,
			"res": UnitStats.res,
			"boss_bonus": UnitStats.boss_bonus,
			"bonus_dodge": UnitStats.bonus_dodge,
			"thief_bonus" : UnitStats.thief_bonus
		},
		"battle_quotes":{
			"death_sentence": death_sentence,
			"before_battle_sentence": before_battle_sentence
		}
	}
	
	# Save Inventory
	# Inventory
	var item_list_data = []
	for item in get_node("Inventory").inventory:
		var item_data = item.save()
		item_list_data.append(item_data)
	save_dict["inventory_data"] = item_list_data
	
	# Does the unit have an AI
	if has_node("AI"):
		save_dict["AI"] = {
			"filename" : get_node("AI").filename,
			"parent" : get_node("AI").get_parent().get_path(),
			"ai_type" : get_node("AI").ai_type,
			"cell_a_x": get_node("AI").tile_to_walk_A.cellPosition.x,
			"cell_a_y": get_node("AI").tile_to_walk_A.cellPosition.y,
			"cell_b_x": get_node("AI").tile_to_walk_B.cellPosition.x,
			"cell_b_y": get_node("AI").tile_to_walk_B.cellPosition.y
		}
	return save_dict

# Load the unit
func load():
	pass
