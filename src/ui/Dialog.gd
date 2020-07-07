extends Control

signal closed

export var TEXT: String
export var NEXT_DIALOG: NodePath
export var SHOW_AVATAR = true

onready var dialogBox = $DialogBox
onready var label = $DialogBox/HSplitContainer/Text
onready var avatar = $DialogBox/HSplitContainer/Avatar
onready var armorAvatar = $DialogBox/HSplitContainer/ArmorAvatar
onready var audioStream = $AudioStreamPlayer

var playing = false
var hurry_pressed = false

func _ready():
	self.label.text = ""

func _input(event):
	if _is_hurry(event) and self.dialogBox.visible:
		self.hurry_pressed = true
		
		if not self.playing:
			self.dialogBox.hide()

# Call this function to start the dialog
func popup():
	get_tree().paused = true
	_set_avatar()
	self.dialogBox.popup_centered()
	_play()
	return self

# Plays the text out for a nicer effect
func _play():
	self.playing = true
	self.audioStream.play()
	for idx in self.TEXT.length():
		# Hurry out of the slow text display if the user hurries it along
		if self.hurry_pressed:
			break

		self.label.text = TEXT.substr(0,idx)
		yield(get_tree().create_timer(0.015), "timeout")
		
	# Ensure all text is shown when hurried or finished playing
	self.label.text = TEXT
	self.audioStream.stop()
	self.playing = false
	
	
func _set_avatar():
	if not SHOW_AVATAR:
		self.avatar.set_visible(false)
		self.armorAvatar.set_visible(false)
	elif GlobalState.armor:
		self.avatar.set_visible(false)
		self.armorAvatar.set_visible(true)
	else:
		self.avatar.set_visible(true)
		self.armorAvatar.set_visible(false)

func _on_DialogBox_popup_hide():
	self.hurry_pressed = false
	if NEXT_DIALOG:
		get_node(NEXT_DIALOG).popup()
	else:
		get_tree().paused = false
	emit_signal("closed")

func _is_hurry(event):
	return (event.is_action_pressed("pause") or
		event.is_action_pressed("ui_accept") or
		event.is_action_pressed("ui_cancel") or
		event.is_action_pressed("shoot1") or
		event.is_action_pressed("dash"))
