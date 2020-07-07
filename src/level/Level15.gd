extends "res://src/level/Base Level.gd"

const police = preload("res://src/actors/Police.tscn")

onready var dialog = $UI/First
onready var blockTiles = $Map/Block
onready var endingTimer = $EndingTimer
onready var endingDialog = $UI/Arrest1

var cops = []


func _ready():
	self.soundPlayer.stop()
	self.blockTiles.set_visible(false)
	self.blockTiles.set_collision_layer_bit(10, false)
	self.currentLevel.bbcode_text = "[right]Level 14[/right]"
	self.dialog.popup()



func _on_BlockTrigger_body_entered(body):
	self.blockTiles.set_visible(true)
	self.blockTiles.set_collision_layer_bit(10, true)
	self.soundPlayer.play("Fade in")


# When the boss dies
func _on_Boss_enemy_killed(name):
	# Create the cops
	var cops = [police.instance(), police.instance(), police.instance(), police.instance()]
	for cop in cops:
		cop.global_position = Vector2(640/2, 24)
		self.actors.add_child(cop)

	# Tell cops to go into formation
	var center = GlobalState.player.global_position
	cops[0].walk_to( center + Vector2(-100, -100) )
	cops[1].walk_to( center + Vector2(-50, -150) )
	cops[2].walk_to( center + Vector2(50, -150) )
	cops[3].walk_to( center + Vector2(100, -100) )
	
	self.set_pause_mode(Node.PAUSE_MODE_PROCESS)
	self.endingTimer.start()

func _on_EndingTimer_timeout():
	self.endingDialog.popup()
func _on_Arrest2_closed():
	# TODO: Switch to the credits
	pass
