extends Node2D

# Map information
export var map_height: int 
export var map_width: int
var all_allies_location = [] # Holds all ally info
var all_enemies_location = [] # holds all enemy info
var grid = [] # Holds all cell data

# Map information has been loaded
signal mapInformationLoaded

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set Map height
	map_height = self.get_meta("height")
	map_width = self.get_meta("width")
	
	# Start 2D Array
	for i in map_width:
		grid.append([])
		for j in map_height:
			grid[i].append(0)
	
	# Cell information
	# [height, type, visible, width, Avd, Def, MovementCost, TileType] -> Tile String Names
	var cellInfoLayer = $"CellInfo"
	for cellInfo in cellInfoLayer.get_children():
		grid[cellInfo.position.x / Cell.CELL_SIZE][cellInfo.position.y / Cell.CELL_SIZE] = Cell.new(Vector2(cellInfo.position.x / Cell.CELL_SIZE, cellInfo.position.y / Cell.CELL_SIZE), \
		cellInfo.get_meta("Avd"), cellInfo.get_meta("Def"), cellInfo.get_meta("MovementCost"), cellInfo.get_meta(("TileType")))
		
	# Set Adj Cells
	for cellArray in grid:
		for cell in cellArray:
			# Left
			if cell.getPosition().x - 1 >= 0:
				cell.adjCells.append(grid[cell.getPosition().x - 1][cell.getPosition().y])
			# Right
			if cell.getPosition().x + 1 < map_width / Cell.CELL_SIZE:
				cell.adjCells.append(grid[cell.getPosition().x + 1][cell.getPosition().y])
			# Up
			if cell.getPosition().y - 1 >= 0:
				cell.adjCells.append(grid[cell.getPosition().x][cell.getPosition().y - 1])
			# Down
			if cell.getPosition().y + 1 < map_height / Cell.CELL_SIZE:
				cell.adjCells.append(grid[cell.getPosition().x][cell.getPosition().y + 1])
	
	# Load Units Information
	var allyInfoLayer = $"Allies"
	var enemyInfoLayer = $"Enemies"
	
	# This should create all the player units -> For now, this will just move the one player unit that I have to the correct location
	#  All Strings available
	#[height, type, visible, width, BonusCrit, BonusDodge, BonusHit, Class, 
#	Consti, Defense, Health, Luck, Magic, MaxHealth, Move, Name, Res, Skill, 
#	Speed, Str, Weapon, buildingPenalty, constiChance, defChance, defaultPenalty, forestPenalty, 
#	fortressPenalty, hillPenalty, isAlly, luckChance, magicChance, maxHPChance, mountainPenalty, 
#	resChance, riverPenalty, seaPenalty, skillChance, speedChance, strChance]

	for allyCellInfo in allyInfoLayer.get_children():
		if (allyCellInfo.get_meta("Name")) == "Eirika":
			$"PlayerUnit".position.x = allyCellInfo.position.x
			$"PlayerUnit".position.y = allyCellInfo.position.y
	
	all_allies_location.append($"PlayerUnit")
	
	for allyUnit in all_allies_location:
		grid[allyUnit.position.x / Cell.CELL_SIZE][allyUnit.position.y / Cell.CELL_SIZE].occupyingUnit = $"PlayerUnit"

	# TO DO Create all the enemies units
			
	
	# Load the information for the map into the camera
	emit_signal("mapInformationLoaded")

# Creates a 2D array for the map to start
func createMap(width, height):
	var map = []
	
	for x in width:
		var col = []
		col.resize(height)
		map.append(col)
	return map