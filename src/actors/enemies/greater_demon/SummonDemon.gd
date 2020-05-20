extends "res://src/actors/enemies/demon/Demon.gd"

onready var summonParticles = $SummonParticles

# Summon critters fizzle into existence
func _ready():
	._ready()
	self.summonParticles.set_emitting(true)

# Summon critters fizzle instead of dropping skulls
func set_die_state():
	self.state = DIE
	self.current_state_time = 0.0
	self.target_state_time = 0.0
	
	# Show death animation
	self.sprite.set_visible(false)
	self.deathSprite.set_visible(false)
	self.shadowSprite.set_visible(false)
	self.hitBox.set_deferred("monitorable", false)
	
	self.deathParticles.set_visible(true)
	self.deathParticles.set_emitting(true)
	self.freeTimer.start()
