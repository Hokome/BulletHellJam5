class_name ProjectilePattern extends Resource

@export var projectile_scene: PackedScene
@export var projectile_count: int
@export var total_angle: float = 360
@export var spacing: float = 0

func shoot(origin: Node2D, parent: Node2D):
	var step := deg_to_rad(total_angle) / projectile_count
	var timer: BattleTimer
	if spacing > 0:
		timer = time_manager.create_timer(spacing, false)
		origin.add_child(timer)
	
	for i in projectile_count:
		var proj := create_projectile(projectile_scene, parent)
		proj.global_position = origin.global_position
		proj.rotate(step * i)
		if timer:
			await timer.timeout
	
	if timer: timer.queue_free()

func create_projectile(scene: PackedScene, parent: Node2D) -> Node2D:
	var node = scene.instantiate()
	parent.add_child(node)
	return node
