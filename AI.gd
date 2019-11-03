extends Node2D

# Type of AI | Default is passive
enum {AGGRESIVE, PASSIVE, PATROL, HEAL}
var ai_type = PASSIVE

var all_attackable_enemies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Find all enemies that the unit can attack
func find_all_enemies_within_range():
	
	# Clear the array
	all_attackable_enemies.clear()
	