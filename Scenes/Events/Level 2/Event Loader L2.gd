extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load events for this level
	BattlefieldInfo.event_system.add_event(L2_Event_Part05.new())
	BattlefieldInfo.event_system.add_event(L2_Event_Part1.new())
	BattlefieldInfo.event_system.add_event(L2_Event_Part2.new())
	BattlefieldInfo.event_system.add_event(L2_Event_Part3.new())
	BattlefieldInfo.event_system.add_event(L2_Event_Part4.new())
	BattlefieldInfo.event_system.add_event(L2_Event_Part5.new())
	
	# Reset the turn manager
	BattlefieldInfo.turn_manager.reset()
	
	# Mid Level Events
	BattlefieldInfo.turn_manager.mid_level_events.append(L2_Event_Mid_10.new())
	BattlefieldInfo.turn_manager.mid_level_events.append(L2_Event_Mid_20.new())
	
	# Add to the tree to prevent a bug
	for event in BattlefieldInfo.turn_manager.mid_level_events:
		add_child(event)