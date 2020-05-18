extends KinematicBody2D

enum { IDLE, RUN_AWAY, DYING }
signal enemy_killed

const SKELLY = preload("res://src/actors/enemies/skeleton/Skeleton.tscn")

export var ACCELERATION = 600
export var FRICTION = 1200
export var MAX_SPEED = 75
export var SUMMON_CHANCE = 25
export var LONGEST_IDLE_TIME = 5.0
export var SHORTEST_IDLE_TIME = 2.5
export var RUN_TIME = 1.0
export var MAX_LIFE = 3
export var SUMMON_RADIUS = 128

var state = IDLE
var direction = Vector2.DOWN
var velocity = Vector2.ZERO
var current_idle_time = 0.0
var target_idle_time = 5.0
var current_run_time = 0.0
var current_life = 1 setget set_life

onready var sprite = $Sprite
onready var shadowSprite = $Shadow
onready var animationPlayer = $AnimationPlayer
onready var sight = $Sight
onready var hitBox = $HitBox
onready var hurtBox = $HurtBox
onready var summonParticles = $SummonParticles
onready var deathParticles = $DeathParticles
onready var iframesTimer = $IframesTimer
onready var freeTimer = $FreeTimer

func _ready():
	randomize()
	self.shadowSprite.set_visible(true)
	self.sprite.set_visible(true)
	self.deathParticles.set_visible(false)
	self.current_life = MAX_LIFE
	self.state = IDLE
	

# State machine per frame
func _physics_process(delta):
	match self.state:
		IDLE:
			self.idle_state(delta)
		RUN_AWAY:
			self.run_state(delta)
		DYING:
			pass

# Sit around randomly
func idle_state(delta):
	# Necromancy is a scardied cat
	if sight.can_see_player():
		self.state = RUN_AWAY
		self.sprite.play("Move")
		return

	# Randomly begin walking
	self.current_idle_time += delta
	if self.current_idle_time >= self.target_idle_time:
		var summon_chance = randi() % 100
		if summon_chance >= SUMMON_CHANCE:
			self.summonParticles.set_emitting(true)
			var instance = SKELLY.instance()
			var new_position = get_random_summoning_position()
			instance.global_position = new_position + global_position
			get_tree().get_root().add_child(instance)
			
			# Randomly choose how long to wait until next summpon
			self.current_idle_time = 0.0
			self.target_idle_time = fmod(randf(), LONGEST_IDLE_TIME) + SHORTEST_IDLE_TIME

func run_state(delta):
	if sight.can_see_player():
		self.current_run_time = 0.0
		self.direction = sight.player.global_position.direction_to(global_position)
		if self.direction.x < 0:
			self.sprite.set_flip_h(true)
		elif self.direction.x > 0:
			self.sprite.set_flip_h(false)

	self.current_run_time += delta
	if self.current_run_time >= RUN_TIME and self.velocity != Vector2.ZERO:
		self.velocity = self.velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		self.velocity = self.velocity.move_toward(self.direction * MAX_SPEED, ACCELERATION * delta)

	self.velocity = move_and_slide(self.velocity)
	if self.velocity == Vector2.ZERO:
		self.state = IDLE
		self.sprite.play("Idle")

# Change the skeletons current HP
func set_life(value):
	current_life = value
	if current_life <= 0:
		die()


# Kill the skeleton
func die():
	self.state = DYING

	# Disable sprites
	self.sprite.set_visible(false)
	self.shadowSprite.set_visible(false)
	
	# The hitbox deactivation must be deferred until after the attack has left
	self.hitBox.set_deferred("monitorable", false)
	
	# Begin death poof
	self.deathParticles.set_visible(true)
	self.deathParticles.set_emitting(true)

	# Free in a bit
	self.freeTimer.start()
	emit_signal("enemy_killed", self)
	

# Gets a random position in the summong radius of the players origin
func get_random_summoning_position():
	var result = Vector2(rand_range(0.0, 1.0), rand_range(0.0, 1.0)).normalized()
	result *= (randi() %  (SUMMON_RADIUS - 32)) + 32
	return result

func _on_HurtBox_area_entered(area):
	self.current_life -= 1
	self.iframesTimer.start()
	self.animationPlayer.play("Iframes Start")

# Free the skeleton from memory when it's done
func _on_FreeTimer_timeout():
	queue_free()

func _on_IframesTimer_timeout():
	self.animationPlayer.play("Iframes Stop")
