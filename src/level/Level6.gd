extends "res://src/level/Base Level.gd"

onready var dialog = $UI/FirstEnter

func _ready():
	if GlobalState.fear_path:
		GlobalState.fear_path = false
		self.dialog.popup()
