extends "res://src/actors/enemies/EnemyBase.gd"
const FLAMES = preload("res://src/particles/Flame.tscn")

onready var flamePivot = $FlamePivot
onready var flame = $FlamePivot/Flame

func set_move_state():
	self.flame.set_enabled(false)
	.set_move_state()

func set_cast_state():
	self.direction = global_position.direction_to(self.sightBox.last_player.global_position).normalized()
	self.flamePivot.set_rotation(self.direction.angle())
	self.flame.set_enabled(true)

func do_idle_state(delta):
	if self.sightBox.can_see_player():
		if is_player_too_close():
			set_move_state()
		else:
			set_cast_state()
		return
	
	.do_idle_state(delta)

func do_cast_state(delta):
	if self.sightBox.can_see_player():
		if is_player_too_close():
			set_move_state()
			return
		.do_cast_state(delta)
		return
	
	set_move_state()

func is_player_too_close():
	var distance = global_position.distance_to(self.sightBox.last_player.global_position)
	return distance <= 16.0
