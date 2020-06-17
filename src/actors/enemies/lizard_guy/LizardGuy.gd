extends "res://src/actors/enemies/lizard_girl/LizardGirl.gd"


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
	self.state = CAST
	self.current_state_time = 0.0
	self.target_state_time = 0.0
