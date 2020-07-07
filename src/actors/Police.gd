extends KinematicBody2D

enum { IDLE, MOVE }

export var ACCELERATION = 500
export var MAX_SPEED = 150

onready var sprite = $AnimatedSprite

var state = IDLE
var velocity = Vector2.ZERO
var target = Vector2.ZERO
var direction = Vector2.ZERO

func _ready():
	_set_idle()


func _target_to_direction(target):
	var translated = target - global_position
	var direction = translated.normalized()
	return direction
	
func _set_sprite(value):
	if self.direction.x < 0:
		self.sprite.set_flip_h(true)
	if self.direction.x > 0:
		self.sprite.set_flip_h(false)
	self.sprite.play(value)
	
func _set_idle():
	self.state = IDLE
	_set_sprite("Idle")
	self.velocity = Vector2.ZERO
	
func _set_move():
	self.direction = _target_to_direction(target)
	self.state = MOVE
	print(self.name, " Moving to: ", self.target, " - ", self.direction)
	_set_sprite("Move")

	
func _physics_process(delta):
	match self.state:
		IDLE:
			pass
		MOVE:
			_do_move(delta)
			
func _do_move(delta):
	self.velocity = self.velocity.move_toward(self.direction * MAX_SPEED, ACCELERATION * delta)
	self.velocity = move_and_slide(self.velocity)
	if global_position.distance_to(target) <= 1:
		_set_idle()
	else:
		self.direction = _target_to_direction(self.target)


# Script NPC to walk towards the target and stop once within a range
func walk_to(target):
	self.target = target
	_set_move()
