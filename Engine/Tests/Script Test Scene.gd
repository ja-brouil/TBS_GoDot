extends Node2D

func _ready():
	range_test()

func range_test():
	var test_array = [1,2,3,4,5,6,7,8,9,10]
	
	var h = 5
	var g = 8
	
	for i in range(g, h, -1):
		print(test_array[i])