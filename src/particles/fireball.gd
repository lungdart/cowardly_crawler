extends KinematicBody2D


export var ACCELERATION = 1000
export var MAX_SPEED = 500

var moving = true
var velocity = Vector2.ZERO
var direction = Vector2.ZERO

onready var sprite = $Sprite
onready var tailParticles = $TailParticles
onready var explodeParticles = $ExplodeParticles
onready var timer = $Timer
onready var animationPlayer = $AnimationPlayer

func _ready():
	self.tailParticles.set_emitting(true)
	self.explodeParticles.set_emitting(false)
	self.sprite.visible = true
	self.animationPlayer.play("Fire")

func init(player_position, mouse_position, offset=0):
	var target_angle = player_position.angle_to_point(mouse_position) + offset
	self.rotation = target_angle
	self.direction = -Vector2(cos(target_angle), sin(target_angle)) 
	self.position = player_position + (self.direction * 24)

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
		#self.animationPlayer.play("Collide")
		self.timer.start()


func _on_Timer_timeout():
	queue_free()
