extends CanvasLayer

signal scene_changed
signal scene_loaded

onready var black_transition = $"Scene Changer/Black"
onready var animation_player = $"Scene Changer/Animation"

var current_scene

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

func manual_swap(path):
	call_deferred("deferred_next_level", path)

func deferred_next_level(path):
	# Anim
	animation_player.play("fade")
	
	# Yield for anim
	yield(animation_player, "animation_finished")
	
	# Load new scene
	var new_level = ResourceLoader.load(path)
	
	# Instance new scene
	current_scene = new_level.instance()
	
	# Set to active scene
	get_tree().get_root().add_child(current_scene)
	
	# Fade backwards
	animation_player.play_backwards("fade")
	
	# Wait until done
	yield(animation_player, "animation_finished")
	
	# Signal
	emit_signal("scene_changed")
	
	# Set current scene
	get_tree().set_current_scene(current_scene)
