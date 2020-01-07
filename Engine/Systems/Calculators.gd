extends Node
# Various calculators

# This is for helpful code to calculate certain math problems
# Get the distance between two tiles
func get_distance_between_two_tiles(tile_a, tile_b):
	return (abs(tile_a.position.x - tile_b.position.x) + abs(tile_a.position.y - tile_b.position.y)) / 16

#  Update a tile with the new info
func update_unit_tile_info(unit, tile):
	# Remove previous unit
	unit.UnitMovementStats.currentTile.occupyingUnit = null
	
	# Set the new tile to the unit
	unit.UnitMovementStats.currentTile = BattlefieldInfo.grid[tile.cellPosition.x][tile.cellPosition.y]
	
	# Set the unit to the new tile
	unit.UnitMovementStats.currentTile.occupyingUnit = unit

# Check if there are more than the constant maximum of letters allowed
func is_string_longer_than_max_constant(string_to_test):
	return string_to_test.length() > Messaging_System.MAX_LETTERS

# Get a random number between a certain value
func get_random_number(lower_bound, upper_bound):
	return randi() % upper_bound + lower_bound
