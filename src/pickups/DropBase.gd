extends StaticBody2D

onready var icon = $Icon
onready var timer = $Timer
onready var animationPlayer = $AnimationPlayer
onready var collisionShape = $Pickup/CollisionShape2D

func _ready():
	self.collisionShape.set_disabled(false)
	self.icon.set_visible(true)
	self.timer.start()


# Override this on each instance
func pick_up():
	pass

func _on_Pickup_body_entered(body):
	self.animationPlayer.play("Pickup")
	pick_up()
	destroy()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Fizzle":
		destroy()
		queue_free()
	if anim_name == "Pickup":
		queue_free()

func _on_Timer_timeout():
	fizzle()

func fizzle():
	self.animationPlayer.play("Fizzle")
	
	
func destroy():
	self.timer.stop()
	self.icon.set_visible(false)
	self.collisionShape.set_disabled(true)
