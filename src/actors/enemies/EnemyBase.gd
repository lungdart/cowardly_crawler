extends KinematicBody2D

enum { IDLE, MOVE, CAST, DIE }
signal enemy_killed

export var ACCELERATION = 800
export var FRICTION = 1200
export var MAX_SPEED = 100
export var MAX_LIFE = 1
export var IDLE_CHANCE = 25
export var MOVE_CHANCE = 75
export var CAST_CHANCE = 0
export var MIN_IDLE_TIME = 0.5
export var MAX_IDLE_TIME = 3.0
export var MIN_MOVE_TIME = 0.5
export var MAX_MOVE_TIME = 3.0

var state = IDLE
var direction = Vector2.DOWN
var velocity = Vector2.ZERO
var current_state_time = 0.0
var target_state_time = 0.0
var current_life = 1 setget set_life
var frozen = false

onready var sprite = $Sprite
onready var shadowSprite = $Shadow
onready var deathSprite = $DeathSprite
onready var animationPlayer = $AnimationPlayer
onready var shaderPlayer = $ShaderPlayer
onready var hitBox = $HitBox
onready var hurtBox = $HurtBox
onready var sightBox = $SightBox
onready var castParticles = $CastParticles
onready var deathParticles = $DeathParticles
onready var frozenTimer = $FrozenTimer
onready var iframesTimer = $IframesTimer
onready var freeTimer = $FreeTimer

func _ready():
	# Initialize scene
	self.hurtBox.connect("area_entered", self, "_on_hurtBox_area_entered")
	self.animationPlayer.connect("animation_finished", self, "_on_animationPlayer_finished")
	self.frozenTimer.connect("timeout", self, "_on_frozenTimer_timeout")
	self.iframesTimer.connect("timeout", self, "_on_iframesTimer_timeout")
	self.freeTimer.connect("timeout", self, "_on_freeTimer_timeout")
	self.shadowSprite.set_visible(true)
	self.sprite.set_visible(true)
	self.deathSprite.set_visible(false)
	self.castParticles.set_visible(true)
	self.deathParticles.set_visible(true)
	
	# Initialize stats
	self.current_life = MAX_LIFE

	# Initialize state machine
	randomize()
	set_idle_state()

# State machine per frame
func _physics_process(delta):
	match self.state:
		IDLE:
			self.do_idle_state(delta)
		MOVE:
			self.do_move_state(delta)
		CAST:
			self.do_cast_state(delta)
		DIE:
			self.do_die_state(delta)
			
func set_idle_state():
	self.sprite.set_animation("Idle")
	self.state = IDLE
	self.current_state_time = 0.0
	self.target_state_time = get_state_time(MIN_IDLE_TIME, MAX_IDLE_TIME)
	
func set_move_state():
	self.sprite.set_animation("Move")
	self.state = MOVE
	self.current_state_time = 0.0
	self.target_state_time = get_state_time(MIN_MOVE_TIME, MAX_MOVE_TIME)

	# Choose random direction
	self.velocity = Vector2.ZERO
	self.direction = get_move_direction()
	if self.direction.x < 0:
		self.sprite.set_flip_h(true)
	elif self.direction.x > 0:
		self.sprite.set_flip_h(false)
	
func set_cast_state():
	self.state = CAST
	self.current_state_time = 0.0
	self.target_state_time = 0.0
	self.castParticles.set_emitting(true)
	
func set_die_state():
	self.state = DIE
	self.current_state_time = 0.0
	self.target_state_time = 0.0
	
	# Show death animation
	self.sprite.set_visible(false)
	self.deathSprite.set_visible(true)
	self.hitBox.set_deferred("monitorable", false)
	self.animationPlayer.play("Death")
	emit_signal("enemy_killed", self)

# Choose a new state when finished idling
func do_idle_state(delta):
	# Randomly begin walking
	self.current_state_time += delta
	if self.current_state_time >= self.target_state_time:
		var chance = randi() % 100
		var setter = get_next_state(chance)
		setter.call_func()

# Move randomly
func do_move_state(delta):
	# Go back to idling when movement finished and actor has come to a stop
	self.current_state_time += delta
	if self.current_state_time >= self.target_state_time and self.velocity == Vector2.ZERO:
		set_idle_state()
		return
	
	# Slow down when movement finished, speed up to max speed when movement ongoing
	if self.current_state_time >= self.target_state_time and self.velocity != Vector2.ZERO:
		var speed = FRICTION * (0.25 if self.frozen else 1.0)
		self.velocity = self.velocity.move_toward(Vector2.ZERO, speed * delta)
	else:
		var speed = MAX_SPEED * (0.25 if self.frozen else 1.0)
		self.velocity = self.velocity.move_toward(self.direction * speed, ACCELERATION * delta)
	
	# Update position
	self.velocity = move_and_slide(self.velocity)

# No-op
func do_cast_state(delta):
	pass

# No-op
func do_die_state(delta):
	pass


func get_next_state(chance):
	if chance > (100 - CAST_CHANCE):
		return funcref(self, "set_cast_state")
	elif chance > (100 - MOVE_CHANCE):
		return funcref(self, "set_move_state")
	else:
		return funcref(self, "set_idle_state")

# Get a random time in seconds betweeon the minimum and maximum
func get_state_time(min_time, max_time):
	var time = fmod(randf(), (max_time-min_time)) + min_time
	return time

# Get a noramlized random move direction
func get_move_direction():
	var direction = Vector2.ZERO
	direction.x = (randi() % 100) - 50
	direction.y = (randi() % 100) - 50
	return direction.normalized()

# Change the enemies current HP
func set_life(value):
	current_life = value
	if current_life <= 0:
		set_die_state()

# Handle being hurt, and magic effects
func _on_hurtBox_area_entered(area):
	if area.name == "HitBox":
		self.current_life -= 1
		self.shaderPlayer.play("Iframes Start")
		self.iframesTimer.start()
	elif area.name == "FreezeBox":
		print("FROZEN")
		self.frozen = true
		self.sprite.get_material().set_shader_param("frozen", true)
		self.frozenTimer.start()

func _on_frozenTimer_timeout():
	self.sprite.get_material().set_shader_param("frozen", false)

func _on_iframesTimer_timeout():
	self.shaderPlayer.play("Iframes Stop")

# Once the death animation finishes, we want to fizzle out the sprites
func _on_animationPlayer_finished(anim_name):
	if anim_name == "Death":
		self.deathParticles.set_visible(true)
		self.deathParticles.set_emitting(true)
		self.deathSprite.set_visible(false)
		self.shadowSprite.set_visible(false)
		self.freeTimer.start()

# Release instance once graphically finished
func _on_freeTimer_timeout():
	queue_free()
