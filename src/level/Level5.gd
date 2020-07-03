extends "res://src/level/Base Level.gd"

onready var blockTiles = $Map/Block
onready var warning = $UI/Warning

func _ready():
	self.blockTiles.set_visible(false)
	self.currentLevel.bbcode_text = "[right]Level 5[/right]"


func _on_Trigger_body_entered(body):
	if GlobalState.level5_block:
		self.warning.popup()
		

func _on_PickupFire_picked_up():
	GlobalState.level5_block = false
	self.blockTiles.set_collision_layer_bit(0, false)
