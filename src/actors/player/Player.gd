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

onready var sprite = $Sprite
onready var shadowSprite = $Shadow
onready var actionPlayer = $ActionPlayer
onready var targetOrigin = $"Target Origin"
onready var lifeUI = $UI/Life
onready var iframesPlayer = $IframesPlayer
onready var iframesTimer = $IframesTimer
onready var deathParticles = $"Death Particles"
onready var targetCursor = $"Target Origin"

onready var projectiles = {
	"fireball": preload("res://src/particles/fireball.tscn")
}
onready var equipped_projectiles = [
	projectiles["fireball"],
	projectiles["fireball"]
]

func _ready():
	self.lifeUI.set_visible(true)
	self.lifeUI.max_life = MAX_LIFE
	self.lifeUI.current_life = CURRENT_LIFE
	self.sprite.play("Idle")
	self.state = IDLE


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
		shoot(0)
		
	if event.is_action_pressed("shoot2"):
		shoot(1)


func update_aim():
	self.target_angle = global_position.angle_to_point(get_global_mouse_position())
	self.targetOrigin.set_rotation(self.target_angle)


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


# Launch projectiles
func shoot(id):
	if id != 0 and id != 1:
		return
	
	var projectile = self.equipped_projectiles[id]
	var instance = projectile.instance()
	instance.rotation = self.target_angle
	instance.direction = -Vector2(cos(self.target_angle), sin(self.target_angle)) 
	instance.position = global_position + (instance.direction * 48)

	get_tree().get_root().add_child(instance)


# Register a hit on the player
# warning-ignore:unused_argument
func _on_Hurtbox_area_entered(area):
	# Only hurt outside of iframes
	if not self.invincible:
		self.lifeUI.current_life -= 1
		
		# Hurt animations unsed when not dead
		if self.lifeUI.current_life > 0:
			self.sprite.stop()
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
