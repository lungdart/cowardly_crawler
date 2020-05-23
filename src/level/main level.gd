extends Node2D

onready var pickups = $Pickups

func _ready():
	GlobalState.level = self
	GlobalState.player = $Actors/Player
	GlobalState.lifeUI = $UI/Life
	GlobalState.spellsUI = $UI/Spells

func add_drop(instance, pos):
	instance.global_position = pos
	pickups.add_child(instance)

func _on_Spells_instance_spell(scene, player_position):
	var instance = scene.instance()
	instance.init(player_position, get_global_mouse_position())
	add_child(instance)
