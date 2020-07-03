extends "res://src/actors/enemies/EnemyBase.gd"

const insults = preload("res://src/particles/Insults.tscn")
const insults2 = preload("res://src/particles/Insults.tscn")

# Flee from player when he's in sight
func do_idle_state(delta):
	if self.sightBox.can_see_player():
		set_move_state()
		return
		
	.do_idle_state(delta)

func do_move_state(delta):
	# Keep fleeing away from the player if he's within sight
	if self.sightBox.can_see_player():
		self.current_state_time = 0.0
		self.direction = self.sightBox.last_player.global_position.direction_to(global_position)
		if self.direction.x < 0:
			self.sprite.set_flip_h(true)
		elif self.direction.x > 0:
			self.sprite.set_flip_h(false)
			
	.do_move_state(delta)

# Summon skellies
func set_cast_state():
	self.state = CAST
	self.current_state_time = 0.0
	self.target_state_time = 0.0
	
	var instance = null
	if self.current_life < int(MAX_LIFE / 2):
		instance = insults2.instance()
	else:
		instance = insults.instance()
	instance.global_position = global_position + Vector2(0, -24)
	get_tree().get_root().add_child(instance)
	
	.set_idle_state()
