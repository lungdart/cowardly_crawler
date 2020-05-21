extends Control

export var max_life = 10 setget set_max_life
export var current_life = 10 setget set_current_life

var initialized = false
onready var lifeCap = $LifeCap
onready var progressBar = $TextureProgress

func _ready():
	initialized = true
	set_max_life(max_life)
	set_current_life(current_life)

func set_max_life(value):
	max_life = value
	if self.initialized:
		self.progressBar.max_value = value
		self.progressBar.rect_size.x = get_bar_length(value)
		self.lifeCap.rect_position.x = get_cap_position(value)
	
func set_current_life(value):
	current_life = value
	if self.initialized:
		self.progressBar.value = value

func get_cap_position(value):
	return 84 + (value * 10)
	
func get_bar_length(value):
	return 4 + (value * 10)


func _on_Life_resized():
	# Resize back to 1:1 scale regardless of window settings
	var screen_size = OS.get_real_window_size()
	var default_x = ProjectSettings.get_setting("display/window/size/width")
	var default_y = ProjectSettings.get_setting("display/window/size/height")
	var x_ratio = 640.0 / float(screen_size.x)
	var y_ratio = 480.0 / float(screen_size.y)
	rect_scale.x = x_ratio
	rect_scale.y = y_ratio

