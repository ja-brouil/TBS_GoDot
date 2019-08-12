# Contains all the statistics needed for movement for the units on the battlefield
class_name Unit_Movement

# Current Tile
var currentTile

# Tiles that you can move to
var allowedMovement = []

# Tiles that you can attack
var allowedAttackRange = []

# Tiles that you can heal
var allowedHealRange = []

# Movement variables
var movementSteps

# Movement Path Queue
var movement_queue = []
var is_moving = false

# Movement Penalties
var defaultPenalty
var mountainPenalty
var hillPenalty
var forestPenalty
var fortressPenalty
var buildingPenalty
var riverPenalty
var seaPenalty

# Constructor
func _init(movementSteps, defaultPenalty, hillPenalty, forestPenalty, fortressPenalty, buildingPenalty, riverPenalty, seaPenalty, mountainPenalty):
	self.movementSteps = movementSteps
	self.defaultPenalty = defaultPenalty
	self.hillPenalty = hillPenalty
	self.forestPenalty = forestPenalty
	self.fortressPenalty = fortressPenalty
	self.buildingPenalty = buildingPenalty
	self.riverPenalty = riverPenalty
	self.seaPenalty = seaPenalty
	self.mountainPenalty = mountainPenalty

# Get which direction you are facing for moving
func get_direction_to_animate(current_tile, next_tile):
	# Left
	if (current_tile.getPosition().x - next_tile.getPosition().x > 0) && (current_tile.getPosition().y - next_tile.getPosition().y == 0):
		pass