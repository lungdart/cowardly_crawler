extends Area2D

var player = null

func can_see_player():
	return self.player != null

func _on_Sight_body_entered(body):
	self.player = body

func _on_Sight_body_exited(body):
	self.player = null
