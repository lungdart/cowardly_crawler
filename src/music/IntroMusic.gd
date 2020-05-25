extends Node2D

export var FADE_IN_TIME = 1.0
export var FADE_OUT_TIME = 1.0


onready var audioPlayer = $AudioStreamPlayer
onready var animationPlayer = $AnimationPlayer

func _ready():
	self.audioPlayer.stop()

func play():
	self.animationPlayer.play("Fade In")
	
func stop():
	self.animationPlayer.play("Fade Out")
