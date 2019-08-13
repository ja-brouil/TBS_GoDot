extends Node2D

const CAMERA_CURSOR_DIFFERENTIAL_FACTOR = 3
const CAMERA_WIDTH = 240
const CAMERA_HEIGTH = 160
var cameraNode

# Update the camera on cursor movement
func _on_Cursor_cursorMoved(direction, cursor_position):
	cameraNode = $"Camera2D"
	match direction:
		"up":
			if abs(cameraNode.position.y - cursor_position.y) <= (Cell.CELL_SIZE * CAMERA_CURSOR_DIFFERENTIAL_FACTOR):
				cameraNode.position.y -= Cell.CELL_SIZE
		"down":
			if abs((cameraNode.position.y + CAMERA_HEIGTH) - cursor_position.y) <= (Cell.CELL_SIZE * CAMERA_CURSOR_DIFFERENTIAL_FACTOR):
				cameraNode.position.y += Cell.CELL_SIZE
		"left":
			if abs(cameraNode.position.x - cursor_position.x) <= (Cell.CELL_SIZE * CAMERA_CURSOR_DIFFERENTIAL_FACTOR):
				cameraNode.position.x -= Cell.CELL_SIZE
		"right":
			if abs((cameraNode.position.x + CAMERA_WIDTH) - cursor_position.x) <= (Cell.CELL_SIZE * CAMERA_CURSOR_DIFFERENTIAL_FACTOR):
				cameraNode.position.x += Cell.CELL_SIZE
	
	# Clamp camera
	clampCameraPosition()

# Update the camera on unit movement


# Sets the parameters for the maximum camera movement once the level is loaded
func _on_Level_mapInformationLoaded():
	cameraNode = $"Camera2D"
	cameraNode.limit_bottom = get_parent().get_node("Level").map_width * Cell.CELL_SIZE
	cameraNode.limit_right = get_parent().get_node("Level").map_height * Cell.CELL_SIZE - 32
	
# Prevent out of bounds for the camera
func clampCameraPosition():
	cameraNode.position.x = clamp(cameraNode.position.x, 0, cameraNode.limit_bottom)
	cameraNode.position.y = clamp(cameraNode.position.y, 0, cameraNode.limit_right)