extends AnimatedSprite

# This class controls which direction the unit should be facing based on the first and next cell
export var movement_animation_speed = 5

func _process(delta):
	if animation == "Highlighted":
		flip_h = true
	elif animation == "Idle":
		flip_h = false

# Returns the direction that the unit should be facing
func get_direction_to_face(starting_cell, destination_cell):
	# Right
	if starting_cell.getPosition().x - destination_cell.getPosition().x < 0 && starting_cell.getPosition().y - destination_cell.getPosition().y == 0:
		animation = "Left"
		flip_h = true

	# Left
	elif starting_cell.getPosition().x - destination_cell.getPosition().x > 0 && starting_cell.getPosition().y - destination_cell.getPosition().y == 0: 
		animation = "Left"
		flip_h = false

	# North
	elif starting_cell.getPosition().x - destination_cell.getPosition().x == 0 && starting_cell.getPosition().y - destination_cell.getPosition().y > 0:
		animation = "Up"
		flip_h = false

	# South
	elif starting_cell.getPosition().x - destination_cell.getPosition().x == 0 && starting_cell.getPosition().y - destination_cell.getPosition().y < 0:
		animation = "Down"
		flip_h = false