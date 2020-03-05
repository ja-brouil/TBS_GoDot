extends Control

var test_array = []
var first
func _ready():
	first = L2_Event_Mid_10.new()
#	var second = L2_Event_Mid_20.new()
	
	test_array.append(first)
#	test_array.append(second)
	add_child(first)
#	add_child(second)

func _input(event):
	if Input.is_action_just_pressed("debug"):
#		var save_game_file = File.new()
#		save_game_file.open("res://Save/event_test.save", File.WRITE)
		
		# Serialize the data and write
		test_array.append(load(first.path).new())
		print(test_array.size())
