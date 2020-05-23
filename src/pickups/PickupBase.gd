extends StaticBody2D


onready var icon = $Icon
onready var animationPlayer = $AnimationPlayer

func _ready():
	animationPlayer.play("Float")


# Override this on each instance
func pick_up():
	pass


func _on_Pickup_body_entered(body):
	pick_up()
	destroy()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Fizzle":
		queue_free()

func destroy():
	self.icon.set_visible(false)
	self.animationPlayer.play("Fizzle")