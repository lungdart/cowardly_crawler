extends "res://src/level/Base Level.gd"

onready var dialog_1 = $Dialogs/Intro1
onready var dialog_grass = $Dialogs/GrassWarning
onready var dialog_grass2 = $Dialogs/GrassWarning2


func _ready():
	# Play the story arch on the first load of this stage only
	if not GlobalState.intro_played:
		self.dialog_1.popup()
		GlobalState.intro_played = true


# Remind the player that he's afraid to go on the grass
func _on_Player_fear(value):
	if GlobalState.fear_path and (value == 11 or value == 12):
		self.dialog_grass.popup()
	elif GlobalState.fear_grass and value == 11:
		self.dialog_grass2.popup()
