extends "res://src/actors/enemies/EnemyBase.gd"


func do_idle_state(delta):
	if self.sightBox.can_see_player():
		set_move_state()
		return
	
func do_move_state(delta):
	# Run towards the enemy and suicide
	if self.sightBox.can_see_player():
		# Get closer to the player as long as hes in sight
		self.current_state_time = 0.0
		self.direction = global_position.direction_to(self.sightBox.last_player.global_position)
		if self.direction.x < 0:
			self.sprite.set_flip_h(true)
		elif self.direction.x > 0:
			self.sprite.set_flip_h(false)

	.do_move_state(delta)
