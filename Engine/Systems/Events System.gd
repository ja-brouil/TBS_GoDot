extends Node

class_name Event_System

var current_event
var next_event

var queue_of_events = []

func _ready():
	BattlefieldInfo.event_system = self

func start_(event):
	current_event = event
	next_event = event.next_event

func _process(delta):
	pass

func remove_event():
	pass