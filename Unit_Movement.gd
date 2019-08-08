# Contains all the statistics needed for movement for the units on the battlefield
class_name Unit_Movement

# Movement variables
var movementSteps

# Movement Penalties
var defaultPenalty
var mountainPenalty
var hillPenalty
var forestPenalty
var fortressPenalty
var buildingPenalty
var riverPenalty
var seaPenalty

# Default Constructor
func _init(movementSteps, defaultPenalty, hillPenalty, forestPenalty, fortressPenalty, buildingPenalty, riverPenalty, seaPenalty):
	pass

func createEmptyUnitMovement() -> Unit_Movement:
	return _init(5,0,0,0,0,0,0,0)