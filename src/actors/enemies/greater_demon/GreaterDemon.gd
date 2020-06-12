extends "res://src/actors/enemies/EnemyBase.gd"


const SUMMONS = [
	preload("SummonImp.tscn"),
	preload("SummonLesserDemon.tscn"),
	preload("SummonDemon.tscn")
]


onready var summonRayCast = $SummonRayCast

export var SUMMON_RADIUS = 128.0
export var SUMMON_RADIUS_PAD = 16.0

# Summon skellies
func set_cast_state():
	.set_cast_state()
	
	# Attempt to find a summon position up to 10 times, then give up
	for n in range(10):
		var new_position = get_random_summoning_position()
		if new_position:
			var summon = SUMMONS[randi() % SUMMONS.size()]
			var instance = summon.instance()
			var new_global_pos = new_position + global_position
			GlobalState.level.add_actor(instance, new_global_pos)
			break
	
	.set_idle_state()
	
func get_random_summoning_position():
	# Pick a random direction and cast to it as far as the summoning circle
	var direction = Vector2(SUMMON_RADIUS, 0)
	direction = direction.rotated(rand_range(0.0, 2 * PI))
	self.summonRayCast.set_cast_to(direction)
	self.summonRayCast.force_raycast_update()
	
	# Verify there is enough room in this direction to pick a position
	var max_length = SUMMON_RADIUS
	if self.summonRayCast.is_colliding():
		max_length = global_position.distance_to(self.summonRayCast.get_collision_point())
	if not max_length > SUMMON_RADIUS_PAD * 2:
		return null

	# Choose a random length within level bounds along the ray cast
	var length = rand_range(SUMMON_RADIUS_PAD, max_length)
	var result = direction.normalized() * length
	if not GlobalState.level.position_inbounds(result):
		return null
		
	# The random position is bounds and not colliding
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
