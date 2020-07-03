extends "res://src/level/Base Level.gd"

onready var dialog = $UI/First
onready var dialog2 = $UI/Encounter1
onready var blockTiles = $Map/Block


func _ready():
	self.soundPlayer.stop()
	self.blockTiles.set_visible(false)
	self.blockTiles.set_collision_layer_bit(10, false)
	self.currentLevel.bbcode_text = "[right]Level 14[/right]"
	self.dialog.popup()



func _on_BlockTrigger_body_entered(body):
	self.dialog2.popup()
	self.blockTiles.set_visible(true)
	self.blockTiles.set_collision_layer_bit(10, true)
	self.soundPlayer.play("Fade in")
