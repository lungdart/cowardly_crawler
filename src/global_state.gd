extends Node

const MEAT_DROP = preload("res://src/pickups/DropMeat.tscn")
const FOOD_DROP = preload("res://src/pickups/DropFood.tscn")

var player = null
var level = null
var lifeUI = null
var spellsUI = null

var spells = []
var dash = false
var armor = false

var left_spell = null
var right_spell = null

var kill_counter = 0
var max_dungeon_level = 0

func _ready():
	randomize()

func add_dash():
	self.dash = true

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

func drop(position):
	var chance = randi() % 100
	if chance >= (100 - 5):
		var instance = MEAT_DROP.instance()
		self.level.add_drop(instance, position)

	elif chance >= (95 - 25):
		var instance = FOOD_DROP.instance()
		self.level.add_drop(instance, position)
