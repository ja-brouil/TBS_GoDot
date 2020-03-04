extends Node

# Load Events
func _ready():
	BattlefieldInfo.event_system.add_event(L1_Event_Part_10.new())
	BattlefieldInfo.event_system.add_event(L1_Event_Part_20.new())
	BattlefieldInfo.event_system.add_event(L1_Event_Part_30.new())
	
	
	# This should only be called here since you can ONLY start on this level. Otherwise, it should always be loading a later level
	BattlefieldInfo.save_load_system.is_loading_level = false
	
	self.queue_free()
