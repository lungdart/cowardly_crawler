extends Node2D

onready var fireballs = [
	$Fireball,
	$Fireball2,
	$Fireball3,
	$Fireball4,
	$Fireball5
]
var readied = false

func _ready():
	self.readied = true

func init(player_position, mouse_position):
	self.fireballs[0].init(player_position, mouse_position, -PI/8)
	self.fireballs[1].init(player_position, mouse_position, -PI/16)
	self.fireballs[2].init(player_position, mouse_position, 0)
	self.fireballs[3].init(player_position, mouse_position, PI/16)
	self.fireballs[4].init(player_position, mouse_position, PI/8)



func _on_Timer_timeout():
	self.queue_free()
