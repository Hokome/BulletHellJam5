extends Node2D

@export var pattern: ProjectilePattern
@export var cooldown: float

var timer: BattleTimer

var shooting := false

func _ready():
	shooting = true
	timer = time_manager.create_timer(randf_range(0, cooldown))
	add_child(timer)
	await timer.timeout
	timer.wait_time = cooldown
	shooting = false

func _process(_delta):
	if !shooting:
		shoot()

func shoot():
	var target := select_target()
	if !target:
		return
	
	shooting = true
	await pattern.shoot(self, battle, (target.global_position - global_position).normalized())
	timer.start()
	await timer.timeout
	
	shooting = false

func select_target() -> UnitController:
	var best_dist = INF
	var best_unit = null
	for u in battle.unit_list:
		var dist = global_position.distance_squared_to(u.global_position)
		if dist < best_dist:
			best_unit = u
			best_dist = best_dist
	return best_unit
