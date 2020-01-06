extends Control

func _ready():
#	range_test()
	pass

#func range_test():
#	var test_array = [1,2,3,4,5,6,7,8,9,10]
#
#	var h = 5
#	var g = 8
#
#	for i in range(g, h, -1):
#		print(test_array[i])

func _input(event):
	pass

func _on_Timer_timeout():
	set_process_input(false)
	set_process_internal(false)
