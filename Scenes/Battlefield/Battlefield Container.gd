extends Node2D

func _ready():
	BattlefieldInfo.battlefield_container = self
	
	# Start the level
	$"Event System".start_events_queue()