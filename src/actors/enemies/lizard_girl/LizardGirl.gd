extends "res://src/actors/enemies/EnemyBase.gd"


onready var weaponSprite = $WeaponOrigin/WeaponSprite
onready var weaponCollision = $HitBox/CastCollision
onready var castTimer = $CastTimer

var last_cast_direction = Vector2.RIGHT

func _ready():
	weaponSprite.set_visible(false)


func set_cast_state():
	# Flip the cast animations and hitboxes around if direction has changed
	var next_cast_direction
	if self.sprite.flip_h:
		next_cast_direction = Vector2.LEFT
	else:
		next_cast_direction = Vector2.RIGHT
	if self.last_cast_direction != next_cast_direction:
		self.last_cast_direction = next_cast_direction
		self.weaponSprite.position.x *= -1
		self.weaponCollision.position.x *= -1
		self.castParticles.position.x *= -1

	self.weaponCollision.set_disabled(false)
	self.animationPlayer.play("Slash")
	self.castTimer.start()
	.set_cast_state()
	


func _on_CastTimer_timeout():
	self.weaponCollision.set_disabled(true)

