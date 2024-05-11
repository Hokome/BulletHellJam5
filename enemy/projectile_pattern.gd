class_name ProjectilePattern extends Resource

@export var projectile_scene: PackedScene
@export var projectile_count: int

func shoot(origin: Node2D, parent: Node2D):
	var step := 2 * PI / projectile_count
	for i in projectile_count:
		var proj := create_projectile(projectile_scene, parent)
		proj.global_position = origin.global_position
		proj.rotate(step * i)

func create_projectile(scene: PackedScene, parent: Node2D) -> Node2D:
	var node = scene.instantiate()
	parent.add_child(node)
	return node
