extends Control


func _ready():
	#TODO: Detect saved game, and enable continue
	pass

func _on_Continue_pressed():
	#TODO: Load saved game into global state
	#TODO: Transition to approriate level
	pass


func _on_NewGame_pressed():
	#TODO: Setup global state
	SceneChanger.change_scene("res://src/level/main level.tscn")
	pass
