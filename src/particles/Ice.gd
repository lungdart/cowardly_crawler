extends StaticBody2D


onready var animationPlayer = $AnimationPlayer
onready var animatedSprite = $Projectile
onready var shadowSprite = $Shadow
onready var timer = $FreeTimer


func _ready():
	self.shadowSprite.set_visible(true)
	self.animatedSprite.set_visible(true)
	self.animationPlayer.play("fall")

func init(player_position, mouse_position):
	global_position = mouse_position
	
func _on_FreeTimer_timeout():
	queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fall":
		self.timer.start()
