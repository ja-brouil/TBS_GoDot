extends Node2D

# Map information
export var map_height: int # cell size
export var map_width: int # cell size
var all_allies_location = [] # Holds all ally info
var all_enemies_location = [] # holds all enemy info
var grid = [] # Holds all cell data
var cell = load("res://Scenes/GUI/Cell/Cell.tscn")

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
		var map_cell_info = cell.instance()
		map_cell_info.init(Vector2(cellInfo.position.x / Cell.CELL_SIZE, cellInfo.position.y / Cell.CELL_SIZE), \
		cellInfo.get_meta("Avd"), cellInfo.get_meta("Def"), cellInfo.get_meta("MovementCost"), cellInfo.get_meta(("TileType")))
		map_cell_info.set_name("map_cell")
		add_child(map_cell_info)
		grid[cellInfo.position.x / Cell.CELL_SIZE][cellInfo.position.y / Cell.CELL_SIZE] = map_cell_info
		
	# Set Adj Cells
	for cellArray in grid:
		for cell in cellArray:
			# Left
			if cell.getPosition().x - 1 >= 0:
				cell.adjCells.append(grid[cell.getPosition().x - 1][cell.getPosition().y])
			# Right
			if cell.getPosition().x + 1 < map_width:
				cell.adjCells.append(grid[cell.getPosition().x + 1][cell.getPosition().y])
			# Up
			if cell.getPosition().y - 1 >= 0:
				var cellToAdd = grid[cell.getPosition().x][cell.getPosition().y - 1]
				cell.adjCells.append(cellToAdd)
			# Down
			if cell.getPosition().y + 1 < map_height:
				cell.adjCells.append(grid[cell.getPosition().x][cell.getPosition().y + 1])
	
	
	# Load Units Information
	all_allies_location.clear()
	all_enemies_location.clear()
	var allyInfoLayer = $"Allies"
	var enemyInfoLayer = $"Enemies"
	
	# This should create all the player units -> For now, this will just move the one player unit that I have to the correct location
	# All Strings available
	#[height, type, visible, width, BonusCrit, BonusDodge, BonusHit, Class, 
#	Consti, Defense, Health, Luck, Magic, MaxHealth, Move, Name, Res, Skill, 
#	Speed, Str, Weapon, buildingPenalty, constiChance, defChance, defaultPenalty, forestPenalty, 
#	fortressPenalty, hillPenalty, isAlly, luckChance, magicChance, maxHPChance, mountainPenalty, 
#	resChance, riverPenalty, seaPenalty, skillChance, speedChance, strChance]
	
	for allyCellInfo in allyInfoLayer.get_children():
		if (allyCellInfo.get_meta("Name")) == "Eirika":
			$"PlayerParty/Eirika".position.x = allyCellInfo.position.x
			$"PlayerParty/Eirika".position.y = allyCellInfo.position.y
			all_allies_location.append($"PlayerParty".get_node("Eirika"))
			$"PlayerParty".get_node("Eirika").UnitMovementStats.currentTile = grid[$"PlayerParty".get_node("Eirika").position.x / Cell.CELL_SIZE][$"PlayerParty".get_node("Eirika").position.y / Cell.CELL_SIZE]
		
		if (allyCellInfo.get_meta("Name")) == "Seth":
			$"PlayerParty".get_node("Seth").position.x = allyCellInfo.position.x
			$"PlayerParty".get_node("Seth").position.y = allyCellInfo.position.y
			all_allies_location.append($"PlayerParty".get_node("Seth"))
			$"PlayerParty".get_node("Seth").UnitMovementStats.currentTile = grid[$"PlayerParty".get_node("Seth").position.x / Cell.CELL_SIZE][$"PlayerParty".get_node("Seth").position.y / Cell.CELL_SIZE]
	
	# Set the occuyping units to the correct cells
	grid[$"PlayerParty".get_node("Eirika").position.x / Cell.CELL_SIZE][$"PlayerParty".get_node("Eirika").position.y / Cell.CELL_SIZE].occupyingUnit = $"PlayerParty".get_node("Eirika")
	grid[$"PlayerParty".get_node("Seth").position.x / Cell.CELL_SIZE][$"PlayerParty".get_node("Seth").position.y / Cell.CELL_SIZE].occupyingUnit = $"PlayerParty".get_node("Seth")

	# Create Enemy Units -> Rewrite this area later
	var enemyList = enemyInfoLayer.get_children()
	$"EnemyParty/Bandit".position.x = enemyList[1].position.x
	$"EnemyParty/Bandit".position.y = enemyList[1].position.y
	$"EnemyParty/Bandit2".position.x = enemyList[2].position.x
	$"EnemyParty/Bandit2".position.y = enemyList[2].position.y
	
	
			
	# Send cell and grid information to the battlefield main so it is easily accessible
	get_parent().grid = self.grid
	get_parent().map_height = self.map_height
	get_parent().map_width = self.map_width
	
	# Load the information for the map into the camera
	emit_signal("mapInformationLoaded")