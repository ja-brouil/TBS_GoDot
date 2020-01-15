extends Control

signal transition_done
signal fade_done

## List of Transitions
var circle = preload("res://assets/transition/circle.png")
var diagonal = preload("res://assets/transition/diagonal.png")
var left_right = preload("res://assets/transition/leftright.png")
var shards = preload("res://assets/transition/shards.png")
var top_down = preload("res://assets/transition/topdown.png")
var all_transitions = []

# Set Random Seed Generator
func _ready():
	all_transitions.append(circle)
	all_transitions.append(diagonal)
	all_transitions.append(left_right)
	all_transitions.append(shards)
	all_transitions.append(top_down)
	randomize()

# Randomize the masks
func set_new_mask():
	var new_transition = all_transitions[randi() % all_transitions.size()]
	$"Combat Trans".material.set_shader_param("mask", new_transition)


func play_transition_forward():
	set_new_mask()
	
	set_original_state()
	
	# Play the transition
	$anim.play("shard_transition")
	
	# Wait until done
	yield($anim, "animation_finished")
	
	# Signal
	emit_signal("transition_done")

func play_fade():
	# Play next part
	$anim.play("fade")
	
	# Wait until done
	yield($anim, "animation_finished")
	
	# Signal
	emit_signal("fade_done")

func set_original_state():
	# Black
	$Black.visible = true
	$Black.color = Color(0,0,0,1)
	
	# Combat Trans
	$"Combat Trans".visible = true
	$"Combat Trans".material.set_shader_param("cutoff", 1.0)