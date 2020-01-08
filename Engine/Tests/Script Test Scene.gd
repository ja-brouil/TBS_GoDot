extends Control

func _ready():
	array_test()

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

func array_test():
	var battlefield_allies = [1,2,3]
	var map_allies = [1,3,4]
	
	for map_unit in map_allies:
		for b_unit in battlefield_allies:
			if b_unit == map_unit:
				print("changed position and stuff")
				break
		
		battlefield_allies.append(map_unit)
	
	for final_unit in battlefield_allies:
		print(final_unit)
		
