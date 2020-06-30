extends "res://src/level/Base Level.gd"

onready var blockTiles = $Map/Block
onready var warning = $UI/Warning
var can_pass = false

func _ready():
	self.blockTiles.set_visible(false)
	self.currentLevel.bbcode_text = "[right]Level 7[/right]"
	
	


func _on_Trigger_body_entered(body):
	if not self.can_pass:
		self.warning.popup()


func _on_PickupIce_picked_up():
	self.can_pass = true
	self.blockTiles.set_collision_layer_bit(0, false)
