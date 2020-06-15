extends Node2D

onready var pickups = $Objects/Pickups
onready var actors = $Objects/Actors
onready var player = $Objects/Player

onready var lifeUI = $UI/Life
onready var spellsUI = $UI/Spells
onready var pauseUI = $UI/Pause
onready var currentLevel = $UI/CurrentLevel

onready var soundPlayer = $SoundPlayer

func _ready():
	GlobalState.level = self
	GlobalState.player = self.player
	GlobalState.lifeUI = self.lifeUI
	GlobalState.spellsUI = self.spellsUI
	
	self.player.set_visible(true)
	self.lifeUI.set_visible(true)
	self.spellsUI.set_visible(true)
	self.pauseUI.set_visible(true)
	self.currentLevel.set_visible(true)
	self.currentLevel.text = "Outside"
	
	for child in self.actors.get_children():
		if child.name != "Player":
			child.connect("enemy_killed", self, "_on_enemy_killed")
			
	self.soundPlayer.play("Fade in")

func position_inbounds(pos):
	return pos.x > 0 and pos.x < 640 and pos.y > 0 and pos.y < 480

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = true
		pauseUI.popup()


# Add a new actor to the level
func add_actor(instance, pos):
	instance.global_position = pos
	self.actors.add_child(instance)

# Add a new pickup to the level
func add_pickup(instance, pos):
	instance.global_position = pos
	self.pickups.add_child(instance)

# Duplicate of add pickup used for enemy drops for clarity
func add_drop(instance, pos):
 add_pickup(instance, pos)

func fade_out():
	self.soundPlayer.play("Fade out")

func _on_enemy_killed():
	GlobalState.kill_counter += 1

func _on_Spells_instance_spell(scene, player_position):
	var instance = scene.instance()
	instance.init(player_position, get_global_mouse_position())
	add_child(instance)

