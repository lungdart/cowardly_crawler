extends KinematicBody2D

enum { IDLE, MOVE, DASH, DEAD }

export var ACCELERATION = 500
export var FRICTION = 1000
export var MAX_SPEED = 150
export var DASH_ACCELERATION = 1000
export var DASH_FRICTION = 2000
export var DASH_MAX_SPEED = 500
export var ARMOR_SPEED_MOD = 0.75
export var ARMOR_ACCELERATION_MOD = 0.5
export var ARMOR_FRICTION_MOD = 2.0
export var MAX_LIFE = 3
export var CURRENT_LIFE = 3
export var IFRAMES = 1.5

var state = IDLE
var dashing = false
var direction = Vector2.DOWN
var velocity = Vector2.ZERO
var target_angle = 0
var invincible = false
var speed_mod = 1.0
var acceleration_mod = 1.0
var friction_mod = 1.0

onready var stageNode = null
onready var UINode = null
onready var spellsNode = null
onready var sprite = $Sprite
onready var armorSprite = $Armor
onready var shadowSprite = $Shadow
onready var hurtBox = $Hurtbox
onready var dashSprite = $DashPivot/ShockWave
onready var dashTimer = $DashTimer
onready var dashParticlePivot = $DashPivot
onready var dashParticles = $DashPivot/DashParticles
onready var dashHitBox = $HitBox/CollisionShape2D
onready var actionPlayer = $ActionPlayer
onready var targetOrigin = $TargetOrigin
onready var iframesPlayer = $IframesPlayer
onready var iframesTimer = $IframesTimer
onready var deathParticles = $DeathParticles
onready var deathSound = $DeathSound
onready var targetCursor = $TargetOrigin

func _ready():
	# Find UI nodes dynamically
	var nodes = get_tree().get_root().get_children()
	for node in nodes:
		if node.name == "Level":
			self.stageNode = node
			break

	# Configure initial state for all nodes
	self.dashParticles.set_emitting(false)
	self.dashParticles.set_visible(true)
	self.deathParticles.set_emitting(false)
	self.dashHitBox.set_disabled(true)
	self.dashSprite.set_visible(false)
	self.sprite.play("Idle")
	self.armorSprite.play("Idle")
	self.iframesPlayer.play("Iframes Stop")
	self.state = IDLE
	
	# Check for armor
	if GlobalState.armor:
		equip_armor()

	# Check for a special position
	if GlobalState.player_position != Vector2.ZERO:
		self.global_position = GlobalState.player_position
		GlobalState.player_position = Vector2.ZERO


func _physics_process(delta):
	match self.state:
		IDLE:
			self.idle_state(delta)
		MOVE:
			self.move_state(delta)
		DASH:
			self.dash_state(delta)
		DEAD:
			return


func _input(event):
	if event.is_action_pressed("dash") and GlobalState.dash:
		if self.state == MOVE:
			self.do_dash()

	if event.is_action_pressed("shoot1"):
		GlobalState.cast_spell("left", global_position)
		
	if event.is_action_pressed("shoot2"):
		GlobalState.cast_spell("right", global_position)


func equip_armor():
	self.speed_mod *= ARMOR_SPEED_MOD
	self.acceleration_mod *= ARMOR_ACCELERATION_MOD
	self.friction_mod *= ARMOR_FRICTION_MOD

	self.armorSprite.set_animation(self.sprite.animation)
	self.sprite.set_visible(false)
	self.armorSprite.set_visible(true)


func unequip_armor():
	self.speed_mod /= ARMOR_SPEED_MOD
	self.acceleration_mod /= ARMOR_ACCELERATION_MOD
	self.friction_mod /= ARMOR_FRICTION_MOD

	self.sprite.set_animation(self.armorSprite.animation)
	self.sprite.set_visible(true)
	self.armorSprite.set_visible(false)


func do_dash():
	self.dashing = true
	self.dashParticlePivot.set_rotation(self.direction.angle() + PI)
	self.invincible = true
	self.actionPlayer.play("Dash Start")
	self.state = DASH


func idle_state(delta):
	if get_input_vector() != Vector2.ZERO:
		self.velocity = Vector2.ZERO
		self.sprite.set_animation("Move")
		self.armorSprite.set_animation("Move")
		self.state = MOVE


func move_state(delta):
	# Continously update movement direction
	set_direction()
		
	# Return to idle when movement stopped
	if self.direction == Vector2.ZERO and self.velocity == Vector2.ZERO:
		self.state = IDLE
		self.sprite.set_animation("Idle")
		self.armorSprite.set_animation("Idle")
		return
	
	# Slow down when input released
	if self.direction == Vector2.ZERO and self.velocity != Vector2.ZERO:
		var friction = FRICTION * self.friction_mod
		self.velocity = self.velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Speed up to max speed when input is held
	elif self.direction != Vector2.ZERO:
		var max_speed = MAX_SPEED * self.speed_mod
		var acceleration = ACCELERATION * self.acceleration_mod
		self.velocity = self.velocity.move_toward(self.direction * max_speed, acceleration * delta)
	
	# Update player position
	self.velocity = move_and_slide(self.velocity)

func dash_state(delta):
	# Slow down to regular max speed after dashing
	var original_max_speed = MAX_SPEED * self.speed_mod
	var dash_friction = DASH_FRICTION * self.friction_mod
	if not self.dashing and self.velocity.length() > original_max_speed:
		self.velocity = self.velocity.move_toward(Vector2.ZERO, dash_friction * delta)
		
	# Once back to speed, go back to move state
	elif not self.dashing:
		self.state = MOVE
		return

	# Dash at a higher speed in a single direction
	else:
		var dash_max_speed = DASH_MAX_SPEED * self.speed_mod
		var dash_acceleration = DASH_ACCELERATION * self.acceleration_mod
		self.velocity = self.velocity.move_toward(self.direction * dash_max_speed, dash_acceleration * delta)
	
	self.velocity = move_and_slide(self.velocity)

func set_direction():
	self.direction = get_input_vector()
	if self.direction.x < 0:
		self.sprite.set_flip_h(true)
		self.armorSprite.set_flip_h(true)
	if self.direction.x > 0:
		self.sprite.set_flip_h(false)
		self.armorSprite.set_flip_h(false)

func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input_vector.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return input_vector.normalized()

# Register a hit on the player
# warning-ignore:unused_argument
func _on_Hurtbox_area_entered(area):
	# Only hurt outside of iframes
	if not self.invincible:
		GlobalState.hurt(1)
		self.hurtBox.set_deferred("monitorable", false)
		
		# Hurt animations unsed when not dead
		if GlobalState.player_current_health > 0:
			self.iframesPlayer.play("Iframes Start")
			self.actionPlayer.play("Hurt")
			self.invincible = true
			self.iframesTimer.start()
	
		# Do a different set of animations for dying
		elif not self.state == DEAD:
			self.state = DEAD
			self.sprite.set_visible(false)
			self.shadowSprite.set_visible(false)
			self.deathParticles.set_visible(true)
			self.deathParticles.set_emitting(true)
			self.deathSound.play()
			self.stageNode.fade_out()
			yield(self.deathSound, "finished")
			var death_screen = load("res://src/ui/DeathScreen.tscn")
			self.stageNode.add_child(death_screen.instance())
			queue_free()

# Turn off iframes when invincibility is finished
func _on_IframesTimer_timeout():
	self.invincible = false
	self.hurtBox.set_deferred("monitorable", true)
	self.iframesPlayer.play("Iframes Stop")


func _on_ActionPlayer_animation_finished(anim_name):
	if anim_name == "Hurt":
		if self.state == IDLE:
			self.actionPlayer.play("Stand Idle")
		else:
			self.actionPlayer.play("Stand Move")

	elif anim_name == "Dash Start":
		self.actionPlayer.play("Dash End")
		self.invincible = false
		self.dashing = false
		
