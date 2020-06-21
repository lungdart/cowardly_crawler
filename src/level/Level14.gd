extends "res://src/level/Base Level.gd"

onready var dialog = $UI/Dialog

func _ready():
	self.currentLevel.bbcode_text = "[right]Level 14[/right]"
	self.dialog.popup()
