extends CanvasLayer


onready var animationPlayer = $AnimationPlayer
onready var menu = $Control/Menu
onready var title = $Control/Title

func _ready():
	self.animationPlayer.play("Fade")


func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().paused = true
	self.menu.popup_centered()


func _on_Continue_pressed():
	#TODO: Load save point
	pass


func _on_Quit_pressed():
	self.menu.set_visible(false)
	self.title.set_visible(false)
	SceneChanger.change_scene("res://src/ui/MainMenu.tscn")
