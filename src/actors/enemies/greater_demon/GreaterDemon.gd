extends "res://src/actors/enemies/EnemyBase.gd"


const SUMMONS = [
	preload("SummonImp.tscn"),
	preload("SummonLesserDemon.tscn"),
	preload("SummonDemon.tscn")
]


export var SUMMON_RADIUS = 128

# Summon skellies
func set_cast_state():
	.set_cast_state()
	
	var summon = SUMMONS[randi() % SUMMONS.size()]
	var instance = summon.instance()
	var new_position = get_random_summoning_position()
	instance.global_position = new_position + global_position
	get_tree().get_root().add_child(instance)
	
	.set_idle_state()
	
func get_random_summoning_position():
	var result = Vector2(rand_range(0.0, 1.0), rand_range(0.0, 1.0)).normalized()
	result *= (randi() %  (SUMMON_RADIUS - 32)) + 32
	return result

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
