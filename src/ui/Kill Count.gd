extends Control

export var COUNT = 0 setget set_count

onready var counter = $Count

func set_count(value):
	print("Setting count to ", value)
	COUNT = value
	self.counter.set_text( num_to_string(COUNT) )
	
func num_to_string(value):
	var result = str(COUNT)
	return result
