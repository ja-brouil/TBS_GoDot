extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set them to off
	$"Blue".visible = false
	$"Red".visible = false
	$"Green".visible = false

func turnOn(color):
	if color == "Red":
		$"Red".visible = true
	elif color == "Blue":
		$"Blue".visible = true
	elif color == "Green":
		$"Green".visible = true

func turnOff(color):
	if color == "Red":
		$"Red".visible = false
	elif color == "Blue":
		$"Blue".visible = false
	elif color == "Green":
		$"Green".visible = false