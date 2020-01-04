extends CanvasLayer

signal scene_changed
signal scene_loaded

onready var black_transition = $"Scene Changer/Black"
onready var animation_player = $"Scene Changer/Animation"

# Call when you want to change the level
# Path = file location for the next scene
# Delay = time between each scene
func change_scene(path, delay = 0.1):
	# Create the delay for timeout
	yield(get_tree().create_timer(delay), "timeout")
	
	# Play fade animation
	animation_player.play("fade")
	
	# Load the animation and level when done
	yield(animation_player, "animation_finished")
	
	# Change scene
	get_tree().change_scene(path)
	
	# Change to new level
	animation_player.play_backwards("fade")
	
	# Scene change is done
	yield(animation_player, "animation_finished")
	
	emit_signal("scene_changed")

func change_scene_to(path, delay = 0.1):
	# Create the delay for timeout
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

func manual_swap_scene(current_node, next_node_path, delay):
	# Delay timeout for the scene 
	yield(get_tree().create_timer(delay), "timeout")
	
	# Play fade animation
	animation_player.play("fade")
	
	# Wait for animation to finish
	yield(animation_player, "animation_finished")
	
	# Hide current node
	current_node.free()
	
	# Set next node
	var loader = ResourceLoader.load(next_node_path)
	current_node = loader.instance()
	get_tree().get_root().add_child(current_node)
	
	# Play animation
	animation_player.play_backwards("fade")
	
	# Wait until animation is finished
	yield(animation_player, "animation_finished")
	emit_signal("scene_changed")