extends KinematicBody2D

onready var words = $Words


func _ready():
	# Show a random insult
	var word_list = self.words.get_children()
	for word in word_list:
		word.set_visible(false)
	word_list[randi() % word_list.size()].set_visible(true)



func _on_Timer_timeout():
	queue_free()
