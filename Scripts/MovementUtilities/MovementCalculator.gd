# Movement Calculator for units
class_name MovementCalculator

# Calculate Movement Blue Squares
static func calculatePossibleMoves(Unit, AllTiles) -> void:
	processTile(Unit.UnitMovementStats.currentTile, Unit.UnitMovementStats, Unit.UnitMovementStats.movementSteps, Unit)
#
	# Light all the blue tiles
	for blueTile in Unit.UnitMovementStats.allowedMovement:
		AllTiles[blueTile.getPosition().x][blueTile.getPosition().y].cellColors.turnOn("Blue")

static func processTile(initialTile, unit_movement, moveSteps, unit):
	# Add initial tile
	unit_movement.allowedMovement.append(initialTile)