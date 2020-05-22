extends Control

signal instance_spell(scene, player_position)

# Empty spell icons
onready var leftEmptyIcon = $LeftEmpty
onready var rightEmptyIcon = $RightEmpty

# Spell lists
onready var fire_spell = {
	"icon": $Fire,
	"scene": preload("res://src/particles/Fireball.tscn"),
	"cooldown": 0.4
}
onready var ice_spell = {
	"icon": $Ice,
	"scene": preload("res://src/particles/Ice.tscn"),
	"cooldown": 2.5
}
onready var spell_list = {
	"fire": fire_spell,
	"ice": ice_spell
}

# Equipped spells and their states
var left_spell = {
	"name": null,
	"spell": null,
	"current_cooldown": 0.0,
	"cooling": false
}
var right_spell = {
	"name": null,
	"spell": null,
	"current_cooldown": 0.0,
	"cooling": false
}


func _ready():
	set_empty("left")
	set_empty("right")
	
	if GlobalState.left_spell and self.spell_list.has(GlobalState.left_spell):
		set_spell("left", GlobalState.left_spell)
	if GlobalState.right_spell and self.spell_list.has(GlobalState.right_spell):
		set_spell("right", GlobalState.right_spell)


func set_empty(side):
	if side == "left":
		self.leftEmptyIcon.set_visible(true)
		if self.left_spell:
			if self.left_spell["spell"]:
				self.left_spell["spell"]["icon"].set_visible(false)
			self.left_spell["spell"] = null
			self.left_spell["current_cooldown"] = 0.0
			self.left_spell["cooling"] = false

	elif side == "right":
		self.rightEmptyIcon.set_visible(true)
		if self.right_spell:
			if self.right_spell["spell"]:
				self.right_spell["spell"]["icon"].set_visible(false)
			self.right_spell["spell"] = null
			self.right_spell["current_cooldown"] = 0.0
			self.right_spell["cooling"] = false


func set_spell(side, spell):
	# Sanity checks
	if not self.spell_list.has(spell):
		print("Bad spell name: ", spell)
		return


	if side == "left":
		# Remove old instance of the spell to allow it to move correctly
		if self.right_spell["name"] == spell:
			print("Moving spell to the left")
			set_empty("right")

		self.leftEmptyIcon.set_visible(false)
		self.left_spell["name"] = spell
		self.left_spell["spell"] = self.spell_list[spell]
		self.left_spell["spell"]["icon"].rect_position.x = 18
		self.left_spell["spell"]["icon"].set_visible(true)
		self.left_spell["spell"]["icon"].set_value(0)

	elif side == "right":
		# Remove old instance of the spell to allow it to move correctly
		if self.left_spell["name"] == spell:
			print("Moving spell to the right")
			set_empty("left")

		self.rightEmptyIcon.set_visible(false)
		self.right_spell["name"] = spell
		self.right_spell["spell"] = self.spell_list[spell]
		self.right_spell["spell"]["icon"].rect_position.x = 106
		self.right_spell["spell"]["icon"].set_visible(true)
		self.right_spell["spell"]["icon"].set_value(0)


func cast_spell(side, player_position):
	var spell = null
	if side == "left":
		spell = self.left_spell
	elif side == "right":
		spell = self.right_spell
		
	if spell["spell"] and not spell["cooling"]:
		spell["current_cooldown"] = spell["spell"]["cooldown"]
		spell["cooling"] = true
		emit_signal("instance_spell", spell["spell"]["scene"], player_position)


func can_cast_spell(side):
	if side == "left" and self.left_spell["spell"]:
		return not self.left_spell["cooling"]
	if side == "right" and self.right_spell["spell"]:
		return not self.right_spell["cooling"]


func _physics_process(delta):
	# Operate the left side cooldown
	for spell in [self.left_spell, self.right_spell]:
		if spell["cooling"]:
			spell["current_cooldown"] -= delta
			if spell["current_cooldown"] <= 0.0:
				spell["cooling"] = false
				spell["current_cooldown"] = 0.0
			spell["spell"]["icon"].value = int(spell["current_cooldown"] / spell["spell"]["cooldown"] * 100)


func _on_Spells_resized():
	# Resize back to 1:1 scale regardless of window settings
	var screen_size = OS.get_real_window_size()
	var default_x = ProjectSettings.get_setting("display/window/size/width")
	var default_y = ProjectSettings.get_setting("display/window/size/height")
	var x_ratio = 640.0 / float(screen_size.x)
	var y_ratio = 480.0 / float(screen_size.y)
	rect_scale.x = x_ratio
	rect_scale.y = y_ratio
