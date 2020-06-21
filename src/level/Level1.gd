extends "res://src/level/Base Level.gd"

onready var blockTiles = $Map/Block
onready var warningDialog = $UI/Warning

var can_pass = false

func _ready():
	self.blockTiles.set_visible(false)
	self.currentLevel.bbcode_text = "[right]Level 1[/right]"


func _on_WarningTrigger_body_entered(body):
	if not self.can_pass:
		self.warningDialog.popup()


func _on_PickupDash_picked_up():
	self.can_pass = true

	# Looks like this can trigger after free due to a bug. Simple check to prevent a crash
	self.blockTiles.set_collision_layer_bit(0, false)
