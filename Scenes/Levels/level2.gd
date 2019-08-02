extends Node

# Map information
export var map_height: int 
export var map_width: int
export var all_map_cell_info = []
export var map2DArray = []

# Map information has been loaded
signal mapInformationLoaded

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set Map height
	map_height = self.get_meta("height")
	map_width = self.get_meta("width")

	# Create 2D array for the map
	map2DArray = createMap(map_width / Cell.CELL_SIZE, map_height / Cell.CELL_SIZE)
	
	# Cell information
	# [height, type, visible, width, Avd, Def, MovementCost, TileType] -> Tile String Names
	var cellInfoLayer = $"CellInfo"
	for cellInfo in cellInfoLayer.get_children():
		all_map_cell_info.append(Cell.new(Vector2(cellInfo.position.x / Cell.CELL_SIZE, cellInfo.position.y / Cell.CELL_SIZE), \
		cellInfo.get_meta("Avd"), cellInfo.get_meta("Def"), cellInfo.get_meta("MovementCost"), cellInfo.get_meta(("TileType"))))
	
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