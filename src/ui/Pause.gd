extends Control

onready var menu = $PopupMenu
onready var quitConfirm = $QuitConfirm
onready var fireIcon = $PopupMenu/Items/Icons/Fire
onready var spell2Icon = $PopupMenu/Items/Icons/Spell2
onready var iceIcon = $PopupMenu/Items/Icons/Ice
onready var windIcon = $PopupMenu/Items/Icons/Wind
onready var armorIcon = $PopupMenu/Items/Icons/Armor
onready var dashIcon = $PopupMenu/Items/Icons/Dash
onready var killCounter = $PopupMenu/Kills/Count


func popup():
	#TODO: Implement these spells
	self.spell2Icon.set_visible(false)
	self.windIcon.set_visible(false)
	
	set_spell("fire", fireIcon)
	set_spell("ice", iceIcon)
	set_spell("wind", windIcon)
	
	set_armor()
	set_dash()
	
	set_kill_counter()
	
	self.menu.popup_centered()


func set_spell(spell, icon):
	if GlobalState.spells.has(spell):
		icon.set_visible(true)
	else:
		icon.set_visible(false)

func set_armor():
	if GlobalState.armor:
		armorIcon.set_visible(true)
	else:
		armorIcon.set_visible(false)
		
func set_dash():
	if GlobalState.dash:
		dashIcon.set_visible(true)
	else:
		dashIcon.set_visible(false)

func set_kill_counter():
	var count = str(GlobalState.kill_counter)
	killCounter.set_text(count)


func _on_PopupMenu_popup_hide():
	# Unpause the game when the menu is closed
	get_tree().paused = false


func _on_Close_pressed():
	self.menu.set_visible(false)


func _on_Quit_pressed():
	self.quitConfirm.popup_centered()


func _on_Quit_confirm_pressed():
	#TODO: Save game
	self.quitConfirm.set_visible(false)
	self.menu.set_visible(false)
	SceneChanger.change_scene("res://src/ui/MainMenu.tscn")


func _on_Quit_cancel_pressed():
	self.menu.set_visible(true)
	self.quitConfirm.set_visible(false)
