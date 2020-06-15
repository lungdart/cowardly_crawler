extends "res://src/level/Base Level.gd"


onready var blockedTiles = $Map/Blocked
func _on_BossZombie_enemy_killed():
	# Looks like this can trigger after free due to a bug. Simple check to prevent a crash
	var ref = weakref(self.blockedTiles)
	if ref.get_ref():
		ref.get_ref().queue_free()
