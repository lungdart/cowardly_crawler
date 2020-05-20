extends "res://src/actors/enemies/EnemyBase.gd"

onready var explosionSprite = $ExplosionSprite

func _ready():
	self.explosionSprite.set_visible(false)
	var hit_boxes = self.hitBox.get_children()
	hit_boxes[0].set_disabled(false)
	hit_boxes[1].set_disabled(true)
	._ready()

func do_idle_state(delta):
	if self.sightBox.can_see_player():
		set_move_state()
		return

	.do_idle_state(delta)

func do_move_state(delta):
	# Run towards the enemy and suicide
	if self.sightBox.can_see_player():
		# Get closer to the player as long as hes in sight
		self.current_state_time = 0.0
		var distance = global_position.distance_to(self.sightBox.last_player.global_position)
		if distance > 16:
			self.direction = global_position.direction_to(self.sightBox.last_player.global_position)
			if self.direction.x < 0:
				self.sprite.set_flip_h(true)
			elif self.direction.x > 0:
				self.sprite.set_flip_h(false)
				
		# Suicide once close enough
		else:
			set_die_state()
			
	.do_move_state(delta)

func set_die_state():
	self.state = DIE
	self.current_state_time = 0.0
	self.target_state_time = 0.0
	
	# Show death animation
	self.sprite.set_visible(false)
	self.explosionSprite.set_visible(true)
	self.explosionSprite.play("Explode")
	var hit_boxes = self.hitBox.get_children()
	hit_boxes[0].set_disabled(true)
	hit_boxes[1].set_disabled(false)
	emit_signal("enemy_killed", self)


func _on_ExplosionSprite_animation_finished():
	self.hitBox.set_deferred("monitorable", false)
	self.explosionSprite.set_visible(false)
	self.deathSprite.set_visible(true)
	self.animationPlayer.play("Death")
