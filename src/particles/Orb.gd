extends KinematicBody2D

export var ACCELERATION = 50
export var MAX_SPEED = 2
export var LIFE_TIME = 5.0

onready var animationPlayer = $AnimationPlayer

var current_lifetime = 0.0
var direction = Vector2.ZERO
var velocity = Vector2.ZERO

func _ready():
	self.direction = global_position.direction_to(GlobalState.player.global_position)
	self.animationPlayer.play("Rotation")

func _physics_process(delta):
	# Die if old enough
	self.current_lifetime += delta
	if self.current_lifetime >= LIFE_TIME:
		die()
		return

	self.velocity = self.velocity.move_toward(self.direction * MAX_SPEED, ACCELERATION * delta)
	var collision = move_and_collide(self.velocity)
	if collision:
		die()

func _on_HitBox_body_entered(body):
	die()
	
func die():
	queue_free()
