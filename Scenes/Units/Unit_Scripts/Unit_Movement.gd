extends Node

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

# Allow Ally Movement
var is_ally = true

# Movement Penalties
var defaultPenalty
var mountainPenalty
var hillPenalty
var forestPenalty
var fortressPenalty
var buildingPenalty
var riverPenalty
var seaPenalty
var ruinsPenalty

# Constructor
func _init():
	self.movementSteps = 5
	self.defaultPenalty = 0
	self.hillPenalty = 1
	self.forestPenalty = 0
	self.fortressPenalty = 0
	self.buildingPenalty = 0
	self.riverPenalty = 0
	self.seaPenalty = 0
	self.mountainPenalty = 0
	self.ruinsPenalty = 0
	is_ally = true

# Clear the arrays
func clear_arrays():
	allowedMovement.clear()
	allowedAttackRange.clear()
	allowedHealRange.clear()
	movement_queue.clear()
