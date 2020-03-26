extends Node2D

class_name MovementRangeRect

func _ready():
	$"Blue/Blue Player".play("Wave")
	$"Red/Red Player".play("Wave")
	$"Green/Green Player".play("Wave")

func turnOn(colorName):
	if colorName == "Red":
		if !$"Red".visible:
			$"Red".visible = true
	elif colorName == "Blue":
		if !$"Blue".visible:
			$"Blue".visible = true
	elif colorName == "Green":
		if !$"Green".visible:
			$"Green".visible = true

func turnOff(colorName):
	if colorName == "Red":
		$"Red".visible = false
	elif colorName == "Blue":
		$"Blue".visible = false
	elif colorName == "Green":
		$"Green".visible = false

func turnEverythingOff():
	$"Red".visible = false
	$"Blue".visible = false
	$"Green".visible = false
