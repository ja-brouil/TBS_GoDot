# Loads the map once the nodes have been loaded
func loadMapInformation(map2DArray, map_width, map_height):
	# Create 2D array for the map
	map2DArray = createMap(map_width / 16, map_height / 16)
	
	# Cell information
	# [height, type, visible, width, Avd, Def, MovementCost, TileType] -> Tile String Names
	var cellInfoLayer = $"CellInfo"
	for cellInfo in cellInfoLayer.get_children():
		all_map_cell_info.append(Cell.new(Vector2(cellInfo.position.x / 16, cellInfo.position.y / 16), \
		cellInfo.get_meta("Avd"), cellInfo.get_meta("Def"), cellInfo.get_meta("MovementCost"), cellInfo.get_meta(("TileType"))))