extends Node2D

@export var speed: float = 100

func select_target() -> UnitController:
	var best_dist = INF
	var best_unit = null
	for u in battle.unit_list:
		var dist = global_position.distance_squared_to(u.global_position)
		if dist < best_dist:
			best_unit = u
			best_dist = best_dist
	return best_unit
