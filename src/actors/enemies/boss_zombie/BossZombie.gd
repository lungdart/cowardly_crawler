extends "res://src/actors/enemies/EnemyBase.gd"

const orb_particle = preload("res://src/particles/Orb.tscn")

# Always walk towards the player, never idle
func do_idle_state(delta):
	set_move_state()

func do_move_state(delta):
	# Constantly walk towards the player
	self.direction = global_position.direction_to(GlobalState.player.global_position)
	if self.direction.x < 0:
		self.sprite.set_flip_h(true)
	elif self.direction.x > 0:
		self.sprite.set_flip_h(false)

	# Apply movement to actor
	var speed = MAX_SPEED * (0.25 if self.frozen else 1.0)
	self.velocity = self.velocity.move_toward(self.direction * speed, ACCELERATION * delta)
	self.velocity = move_and_slide(self.velocity)

	# Only cast spells once close enough
	if not self.sightBox.can_see_player():
		self.current_state_time = 0.0
	else:
		self.current_state_time += delta

	if self.current_state_time >= self.target_state_time:
		self.target_state_time = get_state_time(MIN_MOVE_TIME, MAX_MOVE_TIME)
		self.current_state_time = 0.0
		cast_spells()

func cast_spells():
	var instance = self.orb_particle.instance()
	instance.position += self.direction.normalized() * 32
	instance.set_rotation(global_position.angle_to_point(GlobalState.player.global_position))
	self.add_child(instance)
