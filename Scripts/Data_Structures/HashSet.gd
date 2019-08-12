# Hash Set implementation for GDScript
# Native Code will be way faster than GDScript for this

class_name HashSet

var array = []

func add(value) -> bool:
	if contains(value):
		return false
	array.append(value)
	return true

func remove(value) -> bool:
	if !contains(value):
		return false
	array.remove(array.find(value, 0))
	return true

func contains(value) -> bool:
	return array.has(value)

func clear() -> void:
	array.clear()