extends Node2D

onready var hitBoxShape = $HitBox/CollisionShape2D
onready var particles = $CPUParticles2D

func _ready():
	set_enabled(false)

func set_enabled(value):
	if value:
		hitBoxShape.set_disabled(false)
		particles.set_visible(true)
		particles.set_emitting(true)
	else:
		hitBoxShape.set_disabled(true)
		particles.set_visible(false)
		particles.set_emitting(false)
