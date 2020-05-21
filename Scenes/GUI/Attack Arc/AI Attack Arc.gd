extends Node2D

# Attack line variables needed
var starting_vector = Vector2(0,0)
var ending_vector = Vector2(0,0)
var line_color = Color(1.0, 0, 0)
var line_width = 3

func _draw() -> void:
	draw_line(starting_vector, ending_vector, line_color, line_width)

func update_starting_value(new_starting_location: Vector2) -> void:
	starting_vector = new_starting_location
	update()

func update_ending_value(new_ending_location: Vector2) -> void:
	ending_vector = new_ending_location
	update()

func update_line_color(new_line_color: Color) -> void:
	line_color = new_line_color
	update()

func update_line_width(new_line_width: int) -> void:
	line_width = new_line_width
	update()
