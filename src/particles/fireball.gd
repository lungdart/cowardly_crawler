extends KinematicBody2D


export var ACCELERATION = 1000
export var MAX_SPEED = 500

var moving = true
var velocity = Vector2.ZERO
var direction = Vector2.ZERO

onready var sprite = $Sprite
onready var tailParticles = $"Tail Particles"
onready var explodeParticles = $"Explode Particles"
onready var timer = $Timer

func _ready():
	self.tailParticles.set_emitting(true)
	self.explodeParticles.set_emitting(false)
	self.sprite.visible = true

func _physics_process(delta):
	if moving:
		move(delta)

func move(delta):
	self.velocity = self.velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	var collision = move_and_collide(velocity * delta)
	if collision:
		self.moving = false
		self.sprite.set_visible(false)
		self.tailParticles.set_emitting(false)
		self.explodeParticles.set_emitting(true)
		self.timer.start()


func _on_Timer_timeout():
	queue_free()
