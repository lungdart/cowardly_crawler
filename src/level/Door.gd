extends Node2D

export var LEVEL = 0
export var POSITION = Vector2.ZERO


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		# Moves the player to a spcecified position if needed
		if POSITION != Vector2.ZERO:
			GlobalState.player_position = POSITION
		
		# Update new max dungeon depth
		if GlobalState.max_dungeon_level < LEVEL:
			GlobalState.max_dungeon_level = LEVEL
			
		# Change scene
		var level_path = "res://src/level/Level" + str(LEVEL) +".tscn"
		SceneChanger.change_scene(level_path)
