extends Node

const MEAT_DROP = preload("res://src/pickups/DropMeat.tscn")
const FOOD_DROP = preload("res://src/pickups/DropFood.tscn")

var player = null
var player_position = Vector2.ZERO
var player_max_health = 10 setget _set_max_health
var player_current_health = 10 setget _set_current_health

var level = null
var lifeUI = null
var spellsUI = null

var spells = ["fire", "ice"]
var dash = false
var armor = false setget _set_armor
var armor_max_health = 3 setget _set_max_armor_health
var armor_current_health = 3 setget _set_current_armor_health

var left_spell = "fire"
var right_spell = "ice"

var kill_counter = 0
var max_dungeon_level = 0

var intro_played = false
var fear_grass = true
var fear_path = true


func _ready():
	randomize()

func add_dash():
	self.dash = true

func add_spell(spell_name, side):
	self.spells.append(spell_name)
	self.spellsUI.set_spell(side, spell_name)
	if side == "left":
		self.left_spell = spell_name
	elif side == "right":
		self.right_spell = spell_name
	
func cast_spell(side, pos):
	if side == "left" and left_spell:
		self.spellsUI.cast_spell(side, pos)
	elif side == "right" and right_spell:
		self.spellsUI.cast_spell(side, pos)
		

func heal(value):
	self.player_current_health += value
	
func hurt(value):
	if self.armor:
		self.armor_current_health -= value
	else:
		self.player_current_health -= value

func drop(position):
	var chance = randi() % 100
	if chance >= (100 - 5):
		var instance = MEAT_DROP.instance()
		self.level.add_drop(instance, position)

	elif chance >= (95 - 25):
		var instance = FOOD_DROP.instance()
		self.level.add_drop(instance, position)

func _set_max_health(value):
	player_max_health = value
	self.lifeUI.max_life = value
	
func _set_current_health(value):
	# Can't exceed max health
	if value > self.player_max_health:
		value = self.player_max_health

	player_current_health = value
	self.lifeUI.current_life = value

func _set_armor(value):
	# Newly pickuped armor
	if value and not self.armor:
		armor = true
		self.lifeUI.toggle_armor(true)
		self.player.equip_armor()
		
	# Newly lost armor
	elif not value and self.armor:
		armor = false
		self.lifeUI.toggle_armor(false)
		self.player.unequip_armor()

func _set_max_armor_health(value):
	armor_max_health = value
	self.lifeUI.max_armor = value
	
func _set_current_armor_health(value):
	# Increasing current armor maxes out max armor temporarily
	if value > self.armor_max_health:
		self.lifeUI.max_armor = value
		
	if value <= 0 and self.armor:
		self.armor = false

	armor_current_health = value
	self.lifeUI.current_armor = value
