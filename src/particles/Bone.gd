extends KinematicBody2D

export var ACCELERATION = 50
export var MAX_SPEED = 10

onready var animationPlayer = $AnimationPlayer

var target = Vector2.ZERO ### This must be set before instancing
var direction = Vector2.ZERO
var velocity = Vector2.ZERO

func _ready():
	self.direction = global_position.direction_to(target).normalized()
	self.animationPlayer.play("Throw")

func _physics_process(delta):
	self.velocity = self.velocity.move_toward(self.direction * MAX_SPEED, delta * ACCELERATION)
	
	var collision = move_and_collide(self.velocity)
	if collision:
		die()

func _on_HitBox_body_entered(body):
	die()
	
func die():
	queue_free()
