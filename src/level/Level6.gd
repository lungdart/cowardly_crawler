extends "res://src/level/Base Level.gd"

onready var dialog = $UI/FirstEnter

func _ready():
	self.currentLevel.bbcode_text = "[right]Level 6[/right]"
	
	if GlobalState.fear_path:
		GlobalState.fear_path = false
		self.dialog.popup()
