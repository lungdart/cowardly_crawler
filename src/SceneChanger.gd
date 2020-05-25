extends CanvasLayer

signal scene_changed()

onready var animationPlayer = $AnimationPlayer
onready var control = $Control
onready var black = $Control/ColorRect

func _ready():
	self.black.color = Color(0, 0, 0, 0)
	self.control.set_visible(false)

func change_scene(path, delay=0.0):
	get_tree().paused = true

	self.control.set_visible(true)
	yield(get_tree().create_timer(delay), "timeout")
	
	self.animationPlayer.play("Fade")
	yield(animationPlayer, "animation_finished")

	assert(get_tree().change_scene(path) == OK)
	self.animationPlayer.play_backwards("Fade")
	
	get_tree().paused = false
	emit_signal("scene_changed")
