extends StaticBody2D


onready var icon = $Icon
onready var animationPlayer = $AnimationPlayer

func _ready():
	animationPlayer.play("Float")


# Override this on each instance
func pick_up():
	self.animationPlayer.play("Fizzle")


func _on_Pickup_body_entered(body):
	pick_up()


func _on_AnimationPlayer_animation_finished(anim_name):
	self.icon.set_visible(false)
	if anim_name == "Fizzle":
		queue_free()
