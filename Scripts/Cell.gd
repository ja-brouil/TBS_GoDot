extends Node2D
# Class to represent tiles in the game and all the information that is needed
class_name Cell

# Cell size constant
const CELL_SIZE = 16

# Cell info
var cellPosition = Vector2(0,0)
var avoidanceBonus = 0
var defenseBonus = 0
var movementCost = 1
var occupyingUnit setget setNewUnit, getOccupyingUnit

# Pathfinding information
var hCost = 0
var gCost = 0
var adjCells = []

# UI information
var tileName = "DEFAULT"

func _init(cellPosition, avoidanceBonus, defenseBonus, movementCost, tileName):
	self.cellPosition = cellPosition 
	self.avoidanceBonus = avoidanceBonus
	self.defenseBonus = defenseBonus
	self.movementCost = movementCost
	self.tileName = tileName

func setNewUnit(newUnit):
	occupyingUnit = newUnit

func getOccupyingUnit():
	return occupyingUnit	

func toString():
	return "Cell data: {position} TileName: {tileName} Avoidance: {avd} DefBonus: {def} MoveCost: {mvd} OccuypingUnit: {oUnit}" \
	.format({"position":str(cellPosition),"tileName": tileName, "avd": avoidanceBonus, "def": defenseBonus, "mvd" : movementCost, "oUnit" : getOccupyingUnit()})