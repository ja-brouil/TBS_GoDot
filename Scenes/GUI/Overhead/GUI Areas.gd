extends Node

# Constants
# Top Left
var top_left_position = Vector2(60,40)

# Top Right
var top_right_position = Vector2(180,40)

# Bottom Left
var bottom_left_position = Vector2(60, 120)

# Bottom Right
var bottom_right_position = Vector2(180,120)

# Move the boxes whenever the camera moves
func move_areas(camera_movement_vector):
	$BottomLeft.position = bottom_left_position + camera_movement_vector
	$BottomRight.position = bottom_right_position + camera_movement_vector
	$TopLeft.position = top_left_position + camera_movement_vector
	$TopRight.position = top_right_position + camera_movement_vector
