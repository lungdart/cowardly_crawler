extends "res://src/level/Base Level.gd"

onready var dialog = $UI/FirstEnter


func _ready():
	self.currentLevel.bbcode_text = "[right]Level 11[/right]"

	if GlobalState.fear_grass:
		GlobalState.fear_grass = false
		self.dialog.popup()
