extends Node2D

onready var pickups = $Pickups
onready var killCounter = $UI/Kills
onready var pauseMenu = $UI/Pause
onready var soundPlayer = $AnimationPlayer

func _ready():
	GlobalState.level = self
	GlobalState.player = $Actors/Player
	GlobalState.lifeUI = $UI/Life
	GlobalState.spellsUI = $UI/Spells
	
	for child in $Actors.get_children():
		if child.name != "Player":
			print("Connecting enemy kill counter for ", child.name)
			child.connect("enemy_killed", self, "_on_enemy_killed")
			
	self.soundPlayer.play("Fade in")

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = true
		pauseMenu.popup()
	

func add_drop(instance, pos):
	instance.global_position = pos
	pickups.add_child(instance)

func fade_out():
	self.soundPlayer.play("Fade out")

func _on_enemy_killed():
	GlobalState.kill_counter += 1

func _on_Spells_instance_spell(scene, player_position):
	var instance = scene.instance()
	instance.init(player_position, get_global_mouse_position())
	add_child(instance)

