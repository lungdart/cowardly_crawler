extends "res://src/actors/enemies/EnemyBase.gd"

export var THROW_COOLDOWN = 1.0
var current_cooldown = 0.0

const BOOMERANG = preload("res://src/particles/Bone.tscn")

func do_idle_state(delta):
	current_cooldown += delta
	if self.sightBox.can_see_player() and self.current_cooldown >= THROW_COOLDOWN:
		var instance = BOOMERANG.instance()
		instance.global_position = global_position
		instance.target = self.sightBox.last_player.global_position
		get_tree().get_root().add_child(instance)

		self.current_cooldown = 0.0
		set_move_state()
	
	else:
		.do_idle_state(delta)
