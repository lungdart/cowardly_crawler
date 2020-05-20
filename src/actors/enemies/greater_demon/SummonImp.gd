extends "res://src/actors/enemies/imp/Imp.gd"

onready var summonParticles = $SummonParticles

# Summon critters fizzle into existence
func _ready():
	._ready()
	self.summonParticles.set_emitting(true)

# Summon critters do not drop skulls or call the enemy killed signal
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
	
func _on_ExplosionSprite_animation_finished():
	self.hitBox.set_deferred("monitorable", false)
	self.explosionSprite.set_visible(false)
	self.freeTimer.start()
