extends Control

onready var fireSpell = $Fire
onready var iceSpell = $Ice

var left_spell = null
var left_cooling = false
var left_cooldown = 0.0
var left_current_cooldown = 0.0

var right_spell = null
var right_cooling = false
var right_cooldown = 0.0
var right_current_cooldown = 0.0


func _ready():
	set_fire("left")
	set_cooldown("left", 0.4)

	set_ice("right")
	set_cooldown("right", 2.5)


func set_cooldown(side, value):
	if side == "left":
		self.left_cooling = false
		self.left_cooldown = value
		self.left_current_cooldown = 0.0
	elif side == "right":
		self.right_cooling = false
		self.right_cooldown = value
		self.right_current_cooldown = 0.0


func set_fire(side):
	if side != "left" and side != "right":
		return

	if side == "left":
		self.left_spell = self.fireSpell
		print("Set fire to left: ", self.left_spell)
		self.fireSpell.rect_position.x = 18
	elif side == "right":
		self.right_spell = self.fireSpell
		self.fireSpell.rect_position.x = 106

	self.fireSpell.set_visible(true)
	self.fireSpell.set_value(0)


func set_ice(side):
	if side != "left" and side != "right":
		return

	if side == "left":
		self.left_spell = self.iceSpell
		self.iceSpell.rect_position.x = 18
	elif side == "right":
		self.right_spell = self.iceSpell
		self.iceSpell.rect_position.x = 106

	self.iceSpell.set_visible(true)
	self.iceSpell.set_value(0)


func cast_spell(side):
	if side == "left":
		self.left_current_cooldown = self.left_cooldown
		self.left_cooling = true
		
	elif side == "right":
		self.right_current_cooldown = self.right_cooldown
		self.right_cooling = true


func can_cast_spell(side):
	if side == "left":
		return not self.left_cooling
	
	if side == "right":
		return not self.right_cooling


func _physics_process(delta):
	# Operate the left side cooldown
	if self.left_cooling:
		self.left_current_cooldown -= delta
		self.left_spell.value = int(self.left_current_cooldown / self.left_cooldown * 100)
		if self.left_current_cooldown <= 0.0:
			self.left_cooling = false
			self.left_current_cooldown = 0.0
			
	# Operate the right side cooldown
	if self.right_cooling:
		self.right_current_cooldown -= delta
		self.right_spell.value = int(self.right_current_cooldown / self.right_cooldown * 100)
		if self.right_current_cooldown <= 0.0:
			self.right_cooling = false
			self.right_current_cooldown = 0.0
	
	

func _on_Spells_resized():
	# Resize back to 1:1 scale regardless of window settings
	var screen_size = OS.get_real_window_size()
	var default_x = ProjectSettings.get_setting("display/window/size/width")
	var default_y = ProjectSettings.get_setting("display/window/size/height")
	var x_ratio = 640.0 / float(screen_size.x)
	var y_ratio = 480.0 / float(screen_size.y)
	rect_scale.x = x_ratio
	rect_scale.y = y_ratio
