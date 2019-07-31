extends Node2D

# Map information
export var map_height = 0
export var map_width = 0
export var all_map_cell_info = []

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
		
#	for cellData in all_map_cell_info:
#		print(cellData.toString())