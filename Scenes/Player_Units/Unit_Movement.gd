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