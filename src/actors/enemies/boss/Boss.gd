extends "res://src/actors/enemies/EnemyBase.gd"

const insults = preload("res://src/particles/Insults.tscn")
const insults2 = preload("res://src/particles/Insults2.tscn")
const insults3 = preload("res://src/particles/Insults3.tscn")

onready var dialog1 = $CanvasLayer/First
onready var dialog2 = $CanvasLayer/Stage2
onready var dialog3 = $CanvasLayer/Stage3

var saw_player = false

# Flee from player when he's in sight
func do_idle_state(delta):
	if self.sightBox.can_see_player():
		if not self.saw_player:
			self.dialog1.popup()
			self.saw_player = true
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
	# Don't start casting until the player is seen
	if not self.saw_player:
		set_idle_state()
		return

	self.state = CAST
	self.current_state_time = 0.0
	self.target_state_time = 0.0
	
	var instance = null
	if self.current_life <= int(MAX_LIFE / 4):
		instance = insults3.instance()
	elif self.current_life <= int(MAX_LIFE / 2):
		instance = insults2.instance()
	else:
		instance = insults.instance()
	instance.global_position = global_position + Vector2(0, -24)
	get_tree().get_root().add_child(instance)
	
	.set_idle_state()
	
func set_die_state():
	self.state = DIE
	self.current_state_time = 0.0
	self.target_state_time = 0.0
	
	# Show death animation
	self.sprite.set_visible(false)
	self.deathSprite.set_visible(true)
	self.hitBox.set_deferred("monitorable", false)
	self.animationPlayer.play("Death")
	emit_signal("enemy_killed", self.name)
	
	GlobalState.drop(global_position)

func _on_hurtBox_area_entered(area):
	if area.name == "HitBox":
		self.current_life -= 1
		if self.current_life > 0:
			self.animationPlayer.play("Hit")
			self.shaderPlayer.play("Iframes Start")
			self.iframesTimer.start()
		if self.current_life == int(MAX_LIFE / 2):
			self.dialog2.popup()
		elif self.current_life == int(MAX_LIFE / 4):
			self.dialog3.popup()
	elif area.name == "FreezeBox":
		self.frozen = true
		self.sprite.get_material().set_shader_param("frozen", true)
		self.frozenTimer.start()
