extends CanvasLayer

signal scene_changed

onready var black_transition = $"Scene Changer/Black"
onready var animation_player = $"Scene Changer/Animation"

# Call when you want to change the level
# Path = file location for the next scene
# Delay = time between each scene
func change_scene(path, delay = 0.5):
	# Create the delay for timeoout
	yield(get_tree().create_timer(delay), "timeout")
	
	# Play fade animation
	animation_player.play("fade")
	
	# Load the animation and level when done
	yield(animation_player, "animation_finished")
	
	# Change scene
	get_tree().change_scene_to(path)
	
	# Change to new level
	animation_player.play_backwards("fade")
	
	# Scene change is done
	yield(animation_player, "animation_finished")
	
	emit_signal("scene_changed")