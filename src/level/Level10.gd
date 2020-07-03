extends "res://src/level/Base Level.gd"


onready var blockedTiles = $Map/Blocked

func _ready():
	self.soundPlayer.stop()
	self.currentLevel.bbcode_text = "[right]Level 10[/right]"
	self.blockedTiles.set_collision_layer_bit(10, false)
	self.blockedTiles.set_visible(false)

func _on_BossZombie_enemy_killed():
	GlobalState.level10_block = false

	# Looks like this can trigger after free due to a bug. Simple check to prevent a crash
	self.blockedTiles.set_visible(false)
	self.blockedTiles.set_collision_layer_bit(10, false)
	self.soundPlayer.play("Fade out")


func _on_BlockTrigger_body_entered(body):
	if GlobalState.level10_block:
		self.blockedTiles.set_collision_layer_bit(10, true)
		self.blockedTiles.set_visible(true)
		self.soundPlayer.play("Fade in")
