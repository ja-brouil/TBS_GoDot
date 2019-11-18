extends Node
# Various calculators

# This is for helpful code to calculate certain math problems

# Get the distance between two tiles
func get_distance_between_two_tiles(tile_a, tile_b):
	return abs(tile_a.position.x - tile_b.position.x) + abs(tile_a.position.y - tile_b.position.y)

#  Update a tile with the new info
func update_unit_tile_info(unit, tile):
	# Remove previous unit
	unit.UnitMovementStats.currentTile.occupyingUnit = null
	
	# Set the new tile to the unit
	unit.UnitMovementStats.currentTile = BattlefieldInfo.grid[tile.cellPosition.x][tile.cellPosition.y]
	
	# Set the unit to the new tile
	unit.UnitMovementStats.currentTile.occupyingUnit = unit