extends Area2D

var last_player = null
var player = null

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func can_see_player():
	return self.player != null

func _on_body_entered(body):
	self.player = body
	self.last_player = body

func _on_body_exited(body):
	self.player = null
