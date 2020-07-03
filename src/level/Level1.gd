extends "res://src/level/Base Level.gd"

onready var blockTiles = $Map/Block
onready var warningDialog = $UI/Warning


func _ready():
	self.blockTiles.set_visible(false)
	self.currentLevel.bbcode_text = "[right]Level 1[/right]"


func _on_WarningTrigger_body_entered(body):
	if GlobalState.level1_block:
		self.warningDialog.popup()


func _on_PickupDash_picked_up():
	GlobalState.level1_block = false

	# Looks like this can trigger after free due to a bug. Simple check to prevent a crash
	self.blockTiles.set_collision_layer_bit(0, false)
