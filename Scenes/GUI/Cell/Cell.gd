extends Node2D

# Class to represent tiles in the game and all the information that is needed
class_name Cell

# Cell size constant
const CELL_SIZE = 16

# Color cell
var color_cell_scene = load("res://Scenes/GUI/CellColors/MovementRangeRect.tscn")

# BFS Search
var movement_processed = false

# Cell info
var cellPosition = Vector2(0,0)
var avoidanceBonus = 0
var defenseBonus = 0
var movementCost = 1
var occupyingUnit = null

# Pathfinding information
var hCost = 0
var gCost = 0
var fCost = 0
var adjCells = []
var parentTile = null
var isVisited = false

# Spawn point
var is_spawn_point = false

# UI information
var tileName = "DEFAULT"

# Start the scene after it's been done
func init(cellPosition, avoidanceBonus, defenseBonus, movementCost, tileName) -> void:
	self.cellPosition = cellPosition 
	self.avoidanceBonus = avoidanceBonus
	self.defenseBonus = defenseBonus
	self.movementCost = movementCost
	self.tileName = tileName
	
	# Position
	self.position.x = cellPosition.x * CELL_SIZE
	self.position.y = cellPosition.y * CELL_SIZE
	
	# Set Vector 2
	self.cellPosition.x = cellPosition.x
	self.cellPosition.y = cellPosition.y
	
	# DEBUG
	$Label.text = str(cellPosition.x, "," , cellPosition.y)
	
func _input(event):
	# DEBUG
	if Input.is_action_just_pressed("show_coord_debug"):
		$Label.visible = !$Label.visible

# Heuristic costs
func get_fCost() -> int:
	fCost = hCost + gCost
	return fCost

func getPosition() -> Vector2:
	return cellPosition

func toString() -> String:
	return "Cell data: {position} TileName: {tileName} Avoidance: {avd} DefBonus: {def} MoveCost: {mvd} OccuypingUnit: {oUnit}" \
	.format({"position":str(cellPosition),"tileName": tileName, "avd": avoidanceBonus, "def": defenseBonus, "mvd" : movementCost, "oUnit" : self.occupyingUnit})
