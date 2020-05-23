extends Node

var player = null
var level = null
var lifeUI = null
var spellsUI = null

var spells = []
var left_spell = null
var right_spell = null

var armor = false

func _ready():
	randomize()

func set_armor(value):
	if value:
		self.armor = true
		self.lifeUI.set_armor(true)
		self.player.equip_armor()
	else:
		self.armor = false
		self.lifeUI.set_armor(false)
		self.player.unequip_armor()

func add_spell(spell_name, side):
	self.spells.append(spell_name)
	self.spellsUI.set_spell(side, spell_name)
	
func heal(value):
	self.player.heal(value)
	
