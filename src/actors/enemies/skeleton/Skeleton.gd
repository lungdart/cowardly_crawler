extends KinematicBody2D

enum { IDLE, MOVE, DYING }
signal enemy_killed

export var ACCELERATION = 800
export var FRICTION = 1200
export var MAX_SPEED = 100
export var MOVE_CHANCE = 25
export var LONGEST_STATE_TIME = 3.0
export var MAX_LIFE = 1

var state = IDLE
var direction = Vector2.DOWN
var velocity = Vector2.ZERO
var current_state_time = 0.0
var target_state_time = 1.0
var current_life = 1 setget set_life

onready var sprite = $Sprite
onready var shadowSprite = $Shadow
onready var deathSprite = $DeathSprite
onready var animationPlayer = $AnimationPlayer
onready var hitBox = $Hitbox
onready var hurtBox = $Hurtbox
onready var summonParticles = $SummonParticles
onready var deathParticles = $DeathParticles
onready var freeTimer = $FreeTimer

func _ready():
	randomize()
	self.shadowSprite.set_visible(true)
	self.sprite.set_visible(true)
	self.deathSprite.set_visible(false)
	self.deathParticles.set_visible(false)
	self.current_life = MAX_LIFE
	
	self.summonParticles.set_emitting(true)
	

# State machine per frame
func _physics_process(delta):
	match self.state:
		IDLE:
			self.idle_state(delta)
		MOVE:
			self.move_state(delta)
		DYING:
			pass

# Sit around randomly
func idle_state(delta):
	# Randomly begin walking
	self.current_state_time += delta
	if self.current_state_time >= self.target_state_time:
		var move_chance = randi() % 100
		if move_chance >= MOVE_CHANCE:
			self.sprite.set_animation("Move")
			self.state = MOVE
			
			# Walk for a random amount of time
			self.current_state_time = 0.0
			self.target_state_time = fmod(randf(), LONGEST_STATE_TIME)
			
			# Walk in a random direction
			self.direction.x = (randi() % 100) - 50
			self.direction.y = (randi() % 100) - 50
			self.direction = self.direction.normalized()
			if self.direction.x < 0:
				self.sprite.set_flip_h(true)
			elif self.direction.x > 0:
				self.sprite.set_flip_h(false)

# Move around randomly
func move_state(delta):
	# Go back to idling when movement finished and actor has come to a stop
	self.current_state_time += delta
	if self.current_state_time >= self.target_state_time and self.velocity == Vector2.ZERO:
		self.current_state_time = 0.0
		self.target_state_time = fmod(randf(), LONGEST_STATE_TIME)
		self.state = IDLE
		self.sprite.set_animation("Idle")
		return
	
	# Slow down when movement finished, speed up to max speed when movement ongoing
	if self.current_state_time >= self.target_state_time and self.velocity != Vector2.ZERO:
		self.velocity = self.velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		self.velocity = self.velocity.move_toward(self.direction * MAX_SPEED, ACCELERATION * delta)
	
	# Update position
	self.velocity = move_and_slide(self.velocity)

# Change the skeletons current HP
func set_life(value):
	current_life = value
	if current_life <= 0:
		die()

# Kill the skeleton
func die():
	self.state = DYING

	self.sprite.set_visible(false)
	self.deathSprite.set_visible(true)
	self.animationPlayer.play("Death")
	
	# The hitbox deactivation must be deferred until after the attack has left
	self.hitBox.set_deferred("monitorable", false)
	
	self.freeTimer.start()
	emit_signal("enemy_killed", self)
	

# warning-ignore:unused_argument
func _on_Hurtbox_area_entered(area):
	self.current_life -= 1

# Start the poof particles after the skull finished moving
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Death":
		self.deathParticles.set_visible(true)
		self.deathParticles.set_emitting(true)
		self.deathSprite.set_visible(false)
		self.shadowSprite.set_visible(false)

# Free the skeleton from memory when it's done
func _on_FreeTimer_timeout():
	queue_free()
