extends Node2D


onready var officer = $Police

func _input(event):
	if event.is_action_pressed("shoot1"):
		var mouse_position = get_viewport().get_mouse_position()
		print("Moving officer to: ", mouse_position)
		self.officer.walk_to(mouse_position)
