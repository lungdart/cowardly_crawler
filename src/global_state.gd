extends Node

var player = null
var level = null
var lifeUI = null
var spellsUI = null

var spells = []
var left_spell = null
var right_spell = null

var armor = false

func set_armor(true):
	self.armor = true
	self.player.set_armor(true)
	self.lifeUI.set_armor(true)

func add_spell(spell_name, side):
	self.spells.append(spell_name)
	self.spellsUI.set_spell(side, spell_name)
