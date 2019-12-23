# A simple PriorityQueue
# This isn't optimized at all and should NOT be used for very large arrays as it sorts everytime a new object is added
class_name PriorityQueue

var array = []

func add_first(value):
	array.push_front(value)
	array.sort_custom(CustomSorter, "custom_sort")

func add_last(value):
	array.push_back(value)
	array.sort_custom(CustomSorter, "custom_sort")

func pop_front():
	return array.pop_front()
	
func pop_last():
	return array.pop_back()

func is_empty():
	return array.size() == 0

func get_size():
	return array.size()

func contains(value):
	return array.has(value)

class CustomSorter:
	static func custom_sort(Cell_A, Cell_B):
		if Cell_A.get_fCost() < Cell_B.get_fCost():
			return true
		return false