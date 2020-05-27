extends Node2D

export var LEVEL_PATH = ""


func _on_Area2D_body_entered(body):
	SceneChanger.change_scene(LEVEL_PATH)
