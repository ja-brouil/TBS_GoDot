extends Camera2D

class_name MainCamera

const CAMERA_CURSOR_DIFFERENTIAL_FACTOR = 3
const CAMERA_WIDTH = 240
const CAMERA_HEIGTH = 160

signal camera_moved

# Update the camera on cursor movement
func _on_Cursor_cursorMoved(direction, cursor_position):
	match direction:
		"up":
			if abs(position.y - cursor_position.y) <= (Cell.CELL_SIZE * CAMERA_CURSOR_DIFFERENTIAL_FACTOR):
				position += Vector2(0,-Cell.CELL_SIZE)
				clampCameraPosition()
				emit_signal("camera_moved", position)
		"down":
			if abs((position.y + CAMERA_HEIGTH) - cursor_position.y) <= (Cell.CELL_SIZE * CAMERA_CURSOR_DIFFERENTIAL_FACTOR):
				position += Vector2(0,Cell.CELL_SIZE)
				clampCameraPosition()
				emit_signal("camera_moved", position)
		"left":
			if abs(position.x - cursor_position.x) <= (Cell.CELL_SIZE * CAMERA_CURSOR_DIFFERENTIAL_FACTOR):
				position += Vector2(-Cell.CELL_SIZE,0)
				clampCameraPosition()
				emit_signal("camera_moved", position)
		"right":
			if abs((position.x + CAMERA_WIDTH) - cursor_position.x) <= (Cell.CELL_SIZE * CAMERA_CURSOR_DIFFERENTIAL_FACTOR):
				position += Vector2(Cell.CELL_SIZE,0)
				clampCameraPosition()
				emit_signal("camera_moved", position)
	print(get_canvas_transform().get_origin(), " " , self.position)

# Sets the parameters for the maximum camera movement once the level is loaded
func _on_Level_mapInformationLoaded():
	limit_bottom = BattlefieldInfo.map_width * Cell.CELL_SIZE
	limit_right = BattlefieldInfo.map_height * Cell.CELL_SIZE - 32
	
# Prevent out of bounds for the camera
func clampCameraPosition():
	# Clamp
	position.x = clamp(position.x, 0, limit_right)
	position.y = clamp(position.y, 0, limit_bottom)