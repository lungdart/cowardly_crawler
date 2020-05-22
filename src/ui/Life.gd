extends Control

export var max_armor = 3 setget set_max_armor
export var current_armor = 0 setget set_current_armor
export var max_life = 10 setget set_max_life
export var current_life = 10 setget set_current_life

var initialized = false
onready var mainPortrait = $PortraitUnderlay/MainPortrait
onready var armorPortrait = $PortraitUnderlay/ArmorPortrait
onready var lifeCap = $Life/Cap
onready var lifeBar = $Life/Progress
onready var armorStub = $Armor/Stub
onready var armorCap = $Armor/Cap
onready var armorBar = $Armor/Progress

func _ready():
	initialized = true
	set_max_life(max_life)
	set_current_life(current_life)
	
	self.set_armor(GlobalState.armor)

func hurt(value):
	if self.current_armor > 0:
		self.current_armor -= value
		if self.current_armor <= 0:
			self.set_armor(false)
	else:
		self.current_life -= value

func set_max_life(value):
	max_life = value
	if self.initialized:
		self.lifeBar.max_value = value
		self.lifeBar.rect_size.x = get_life_bar_length(value)
		self.lifeCap.rect_position.x = get_life_cap_position(value)
	
func set_current_life(value):
	current_life = value
	if self.initialized:
		self.lifeBar.value = value
		
func set_max_armor(value):
	max_armor = value
	if self.initialized:
		self.armorBar.max_value = value
		self.armorBar.rect_size.x = get_armor_bar_length(value)
		self.lifeCap.rect_position.x = get_armor_cap_position(value)
	
func set_current_armor(value):
	current_armor = value
	if self.initialized:
		self.armorBar.value = value

func get_life_cap_position(value):
	return 84 + (value * 10)
	
func get_life_bar_length(value):
	return 4 + (value * 10)
	
func get_armor_cap_position(value):
	return 84 + (value * 10)
	
func get_armor_bar_length(value):
	return 4 + (value * 10)

func set_armor(value):
	if value:
		self.current_armor = self.max_armor
		self.armorBar.set_visible(true)
		self.armorCap.set_visible(true)
		self.armorStub.set_visible(true)
		self.mainPortrait.set_visible(false)
		self.armorPortrait.set_visible(true)
	else:
		self.current_armor = 0
		self.armorBar.set_visible(false)
		self.armorCap.set_visible(false)
		self.armorStub.set_visible(false)
		self.mainPortrait.set_visible(true)
		self.armorPortrait.set_visible(false)

func _on_Life_resized():
	# Resize back to 1:1 scale regardless of window settings
	var screen_size = OS.get_real_window_size()
	var default_x = ProjectSettings.get_setting("display/window/size/width")
	var default_y = ProjectSettings.get_setting("display/window/size/height")
	var x_ratio = 640.0 / float(screen_size.x)
	var y_ratio = 480.0 / float(screen_size.y)
	rect_scale.x = x_ratio
	rect_scale.y = y_ratio

