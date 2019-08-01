extends Node2D

var cameraPosition
const CAMERA_CURSOR_DIFFERENTIAL_FACTOR = 3

func _on_Cursor_cursorMoved(direction, cursor_position):
	match direction:
		"up":
			if abs($"Camera2D".position.y - cursor_position.y) <= (Cell.CELL_SIZE * CAMERA_CURSOR_DIFFERENTIAL_FACTOR):
				$"Camera2D".position.y -= Cell.CELL_SIZE
		"down":
			if abs($"Camera2D".position.y - cursor_position.y) <= (Cell.CELL_SIZE * CAMERA_CURSOR_DIFFERENTIAL_FACTOR):
				$"Camera2D".position.y += Cell.CELL_SIZE

func _on_Level_mapInformationLoaded():
	$"Camera2D".limit_bottom = get_parent().get_node("Level").map_width * Cell.CELL_SIZE
	$"Camera2D".limit_right = get_parent().get_node("Level").map_height * Cell.CELL_SIZE