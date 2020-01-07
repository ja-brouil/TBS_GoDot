extends Node

# Load Events
func _ready():
	BattlefieldInfo.event_system.add_event(L1_Event_Part_10.new())
	BattlefieldInfo.event_system.add_event(L1_Event_Part_20.new())
	BattlefieldInfo.event_system.add_event(L1_Event_Part_30.new())