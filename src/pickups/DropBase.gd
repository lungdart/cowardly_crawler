extends StaticBody2D

onready var icon = $Icon
onready var timer = $timer
onready var animationPlayer = $AnimationPlayer
onready var collisionShape = $Pickup/CollisionShape2D

func _ready():
	self.timer.start()


# Override this on each instance
func pick_up():
	self.icon.set_visible(false)
	self.animationPlayer.play("Fizzle")
	self.timer.stop()


func _on_Pickup_body_entered(body):
	pick_up()
	destroy()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Fizzle":
		queue_free()

func _on_Timer_timeout():
	destroy()

func destroy():
	self.icon.set_visible(false)
	self.collisionShape.set_disabled(true)
	self.animationPlayer.play("Fizzle")
