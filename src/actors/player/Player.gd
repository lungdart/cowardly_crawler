extends KinematicBody2D

enum { IDLE, MOVE, DASH, DEAD }

export var ACCELERATION = 500
export var FRICTION = 500
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
var direction = Vector2.DOWN
var velocity = Vector2.ZERO
var target_angle = 0
var invincible = false
var speed_mod = 1.0
var acceleration_mod = 1.0
var friction_mod = 1.0

onready var stageNode = get_tree().get_root().get_child(1)
onready var UINode = stageNode.get_node("UI")
onready var lifeNode = UINode.get_node("Life")
onready var spellsNode = UINode.get_node("Spells")
onready var sprite = $Sprite
onready var armorSprite = $Armor
onready var shadowSprite = $Shadow
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
onready var targetCursor = $TargetOrigin

func _ready():
	self.dashParticles.set_emitting(false)
	self.deathParticles.set_emitting(false)
	self.dashHitBox.set_disabled(true)
	self.dashSprite.set_visible(false)
	self.lifeNode.set_visible(true)
	self.lifeNode.max_life = MAX_LIFE
	self.lifeNode.current_life = CURRENT_LIFE
	self.sprite.play("Idle")
	self.armorSprite.play("Idle")
	self.state = IDLE
	
	if GlobalState.armor:
		equip_armor()
	else:
		unequip_armor()


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
	update_aim()


func _input(event):
	if event.is_action_pressed("dash"):
		if self.state == MOVE:
			start_dash()
			self.state = DASH

	if event.is_action_pressed("shoot1"):
		self.spellsNode.cast_spell("left", global_position)
		
	if event.is_action_pressed("shoot2"):
		self.spellsNode.cast_spell("right", global_position)


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
	
func start_dash():
	self.dashTimer.start()
	self.dashHitBox.set_disabled(false)
	self.dashSprite.set_visible(true)
	self.dashParticles.set_emitting(true)
	self.dashParticlePivot.set_rotation(self.direction.angle() + PI)
	self.invincible = true
	
func stop_dash():
	self.dashHitBox.set_disabled(true)
	self.dashSprite.set_visible(false)
	self.dashParticles.set_emitting(false)
	self.invincible = false

func update_aim():
	self.target_angle = global_position.angle_to_point(get_global_mouse_position())
	self.targetOrigin.set_rotation(self.target_angle)


func heal(value):
	self.lifeNode.current_life += value

# warning-ignore:unused_argument
func idle_state(delta):
	if get_input_vector() != Vector2.ZERO:
		self.sprite.set_animation("Move")
		self.state = MOVE


func move_state(delta):
	# Continously update movement direction
	set_direction()
		
	# Return to idle when movement stopped
	if self.direction == Vector2.ZERO and self.velocity == Vector2.ZERO:
		self.state = IDLE
		self.sprite.set_animation("Idle")
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
	if self.dashTimer.is_stopped() and self.velocity.length() > original_max_speed:
		stop_dash()
		self.velocity = self.velocity.move_toward(Vector2.ZERO, dash_friction * delta)
		
	# Once back to speed, go back to move state
	elif self.dashTimer.is_stopped():
		stop_dash()
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
		self.lifeNode.hurt(1)
		
		if GlobalState.armor and self.lifeNode.current_armor <= 0:
			# TODO: Broken armor animation
			self.unequip_armor()
		
		# Hurt animations unsed when not dead
		if self.lifeNode.current_life > 0:
			self.sprite.stop()
			self.armorSprite.stop()
			self.iframesPlayer.play("Iframes Start")
			self.actionPlayer.play("Hurt")
			self.invincible = true
			self.iframesTimer.start()
	
		# Do a different set of animations for dying
		else:
			self.state = DEAD
			self.sprite.set_visible(false)
			self.shadowSprite.set_visible(false)
			self.targetCursor.set_visible(false)
			self.deathParticles.set_visible(true)
			self.deathParticles.set_emitting(true)


# Turn off iframes when invincibility is finished
func _on_IframesTimer_timeout():
	self.invincible = false
	self.iframesPlayer.play("Iframes Stop")


func _on_ActionPlayer_animation_finished(anim_name):
	if anim_name == "Hurt":
		self.actionPlayer.play("Stand")
		self.sprite.play("IDLE")
		self.state = IDLE
