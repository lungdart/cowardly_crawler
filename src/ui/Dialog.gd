extends Control

signal closed

export var AVATAR_TEXTURE: Texture
export var TEXT: String
export var NEXT_DIALOG: NodePath


onready var dialogBox = $DialogBox
onready var label = $DialogBox/HSplitContainer/Text
onready var avatar = $DialogBox/HSplitContainer/Avatar
onready var audioStream = $AudioStreamPlayer

func _ready():
	self.label.text = ""
	self.avatar.texture = AVATAR_TEXTURE

# Call this function to start the dialog
func popup():
	get_tree().paused = true
	self.dialogBox.popup_centered()
	_play()
	return self

# Plays the text out for a nicer effect
func _play():
	self.audioStream.play()
	for idx in self.TEXT.length():
		self.label.text = TEXT.substr(0,idx)
		yield(get_tree().create_timer(0.015), "timeout")
	self.audioStream.stop()

func _on_DialogBox_popup_hide():
	if NEXT_DIALOG:
		get_node(NEXT_DIALOG).popup()
	else:
		get_tree().paused = false
	emit_signal("closed")
