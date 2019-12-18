extends Spawn_Event

# Get Spawn points


func process_spawning_event():
	pass

func done_spawning_enemies():
	self.queue_free()