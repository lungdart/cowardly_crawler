extends Node2D

export var LEVEL_PATH = ""
export var POSITION = Vector2.ZERO


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		if POSITION != Vector2.ZERO:
			GlobalState.player_position = POSITION
		SceneChanger.change_scene(LEVEL_PATH)
