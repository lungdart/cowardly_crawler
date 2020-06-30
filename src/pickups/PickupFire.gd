extends "res://src/pickups/PickupBase.gd"

func pick_up():
	GlobalState.add_spell("fire2", "left")
