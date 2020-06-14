extends StaticBody2D


onready var icon = $Icon
onready var animationPlayer = $AnimationPlayer
onready var dialog = $CanvasLayer/Dialog

func _ready():
	self.icon.set_visible(true)
	self.animationPlayer.play("Float")


func _on_Pickup_body_entered(body):
	self.icon.set_visible(false)
	self.animationPlayer.play("Fizzle")
	yield(self.dialog.popup(), "closed")

	pick_up()
	queue_free()


# Override this on each instance
func pick_up():
	pass
