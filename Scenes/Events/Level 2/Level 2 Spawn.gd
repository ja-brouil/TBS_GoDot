extends Spawn_Event

# Get Spawn points
var spawn_points = BattlefieldInfo.spawn_points

func process_spawning_event(turn_number):
	# Is it an even number?
	if turn_number % 2 == 0:
		# Spawn Enemies
		for spawn_point in spawn_points:
			pass
	
	# Move Vezarius back
	if turn_number == 2:
		pass

func done_spawning_enemies():
	self.queue_free()
	