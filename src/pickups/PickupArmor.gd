extends "res://src/pickups/PickupBase.gd"

func pick_up():
	GlobalState.set_armor(true)
