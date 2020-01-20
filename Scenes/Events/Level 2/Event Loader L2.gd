extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load events for this level
	BattlefieldInfo.event_system.add_event(L3_Event_Part10.new())
	
#	# Add to the tree to prevent a bug
#	for event in BattlefieldInfo.turn_manager.mid_level_events:
#		add_child(event)
