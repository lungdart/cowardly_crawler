extends Node2D

func _ready():
	GlobalState.level = self
	GlobalState.player = $Actors/Player
	GlobalState.lifeUI = $UI/Life
	GlobalState.spellsUI = $UI/Spells

func _on_Spells_instance_spell(scene, player_position):
	var instance = scene.instance()
	instance.init(player_position, get_global_mouse_position())
	add_child(instance)
