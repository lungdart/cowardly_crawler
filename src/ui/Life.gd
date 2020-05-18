extends Control

export var max_life = 3 setget set_max_life
export var current_life = 3 setget set_current_life

onready var max_texture = $Max
onready var current_texture = $Current

func set_max_life(value):
	max_life = value
	max_texture.rect_size.x = value * 16
	
func set_current_life(value):
	current_life = value
	current_texture.rect_size.x = value * 16
	
	if current_life <= 0:
		current_texture.set_visible(false)



