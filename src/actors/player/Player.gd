extends KinematicBody2D

enum { IDLE, MOVE, DEAD }

export var ACCELERATION = 1000
export var FRICTION = 1500
export var MAX_SPEED = 300
export var MAX_LIFE = 3
export var CURRENT_LIFE = 3
export var IFRAMES = 1.5

var state = IDLE
var direction = Vector2.DOWN
var velocity = Vector2.ZERO
var target_angle = 0
var invincible = false

onready var stageNode = get_tree().get_root().get_child(1)
onready var UINode = stageNode.get_node("UI")
onready var lifeNode = UINode.get_node("Life")
onready var spellsNode = UINode.get_node("Spells")
onready var sprite = $Sprite
onready var armorSprite = $Armor
onready var shadowSprite = $Shadow
onready var actionPlayer = $ActionPlayer
onready var targetOrigin = $TargetOrigin
onready var iframesPlayer = $IframesPlayer
onready var iframesTimer = $IframesTimer
onready var deathParticles = $DeathParticles
onready var targetCursor = $TargetOrigin

func _ready():
	self.lifeNode.set_visible(true)
	self.lifeNode.max_life = MAX_LIFE
	self.lifeNode.current_life = CURRENT_LIFE
	self.sprite.play("Idle")
	self.armorSprite.play("Idle")
	self.state = IDLE
	
	set_armor(GlobalState.armor)


func _physics_process(delta):
	match self.state:
		IDLE:
			self.idle_state(delta)
		MOVE:
			self.move_state(delta)
		DEAD:
			return
	update_aim()


func _input(event):
	if event.is_action_pressed("shoot1"):
		self.spellsNode.cast_spell("left", global_position)
		
	if event.is_action_pressed("shoot2"):
		self.spellsNode.cast_spell("right", global_position)


func set_armor(value):
	if value:
		self.armorSprite.set_animation(self.sprite.animation)
		self.sprite.set_visible(false)
		self.armorSprite.set_visible(true)
	else:
		self.sprite.set_animation(self.armorSprite.animation)
		self.sprite.set_visible(true)
		self.armorSprite.set_visible(false)

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
	# Set direction
	var input_vector = get_input_vector()
	if input_vector.x < 0:
		self.sprite.set_flip_h(true)
	if input_vector.x > 0:
		self.sprite.set_flip_h(false)
		
	# Return to idle when movement stopped
	if input_vector == Vector2.ZERO and self.velocity == Vector2.ZERO:
		self.state = IDLE
		self.sprite.set_animation("Idle")
		return
	
	# Slow down when input released
	if input_vector == Vector2.ZERO and self.velocity != Vector2.ZERO:
		self.velocity = self.velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	# Speed up to max speed when input is held
	elif input_vector != Vector2.ZERO:
		self.velocity = self.velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	
	# Update player position
	self.velocity = move_and_slide(self.velocity)


# Calculates unit vector from player input
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
			self.set_armor(false)
		
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
