extends Node2D

# Map information
export var map_height: int 
export var map_width: int
var all_map_cell_info = []
var all_allies_location = []
var all_enemies_location = []

# Map information has been loaded
signal mapInformationLoaded

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set Map height
	map_height = self.get_meta("height")
	map_width = self.get_meta("width")
	
	# Cell information
	# [height, type, visible, width, Avd, Def, MovementCost, TileType] -> Tile String Names
	var cellInfoLayer = $"CellInfo"
	for cellInfo in cellInfoLayer.get_children():
		all_map_cell_info.append(Cell.new(Vector2(cellInfo.position.x / Cell.CELL_SIZE, cellInfo.position.y / Cell.CELL_SIZE), \
		cellInfo.get_meta("Avd"), cellInfo.get_meta("Def"), cellInfo.get_meta("MovementCost"), cellInfo.get_meta(("TileType"))))
	
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
			$"PlayerUnit".position.y = allyCellInfo.position.y -16
	
	all_allies_location.append($"PlayerUnit")
	
	for allyUnit in all_allies_location:
		for cellData in all_map_cell_info:
			if $"PlayerUnit".position.x / Cell.CELL_SIZE == cellData.cellPosition.x && $"PlayerUnit".position.y / Cell.CELL_SIZE == cellData.cellPosition.y:
				cellData.occupyingUnit = true

	
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