extends Node2D

export var LEVEL = 0
export var POSITION = Vector2.ZERO
export var GO_BACK = false

onready var dialog = $CanvasLayer/Dialog


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		# Wait for confirmation to change scenes when going back
		if GO_BACK:
			get_tree().paused = true
			self.dialog.popup_centered()
			return
		
		change_scene(LEVEL, POSITION)


func change_scene(level, pos):
	# Moves the player to a spcecified position if needed
	if pos != Vector2.ZERO:
		GlobalState.player_position = pos
		
	# Update new max dungeon depth
	if GlobalState.max_dungeon_level < level:
		GlobalState.max_dungeon_level = level
			
	# Change scene
	var level_path = "res://src/level/Level" + str(level) +".tscn"
	SceneChanger.change_scene(level_path)


func _on_OK_pressed():
	get_tree().paused = false
	change_scene(0, POSITION)


func _on_Dialog_popup_hide():
	get_tree().paused = false


func _on_Cancel_pressed():
	self.dialog.hide()
