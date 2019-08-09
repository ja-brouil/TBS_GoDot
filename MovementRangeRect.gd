extends Node2D

class_name MovementRangeRect

func turnOn(colorName):
	if colorName == "Red":
		$"Red".visible = true
	elif colorName == "Blue":
		$"Blue".visible = true
	elif colorName == "Green":
		$"Green".visible = true

func turnOff(color):
	if color == "Red":
		$"Red".visible = false
	elif color == "Blue":
		$"Blue".visible = false
	elif color == "Green":
		$"Green".visible = false