extends "res://src/pickups/DropBase.gd"


func pick_up():
	GlobalState.heal(1)
