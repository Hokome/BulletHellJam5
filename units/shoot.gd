extends ActionLeaf

@export var pattern: ProjectilePattern
@export var is_boss := false
@export var offset_angle := PI

var is_shooting := false
var started_shooting := false

func _ready():
	aim_vector = aim_vector.rotated(offset_angle)

func before_run(actor: Node, blackboard: Blackboard):
	started_shooting = false

func tick(actor: Node, blackboard: Blackboard) -> int:
	if !started_shooting:
		shoot_async(actor)
	if !is_shooting: return SUCCESS
	
	return RUNNING

var aim_vector := Vector2.RIGHT

func shoot_async(actor: Node2D):
	is_shooting = true
	started_shooting = true
	
	if is_boss:
		await pattern.shoot(actor, battle, aim_vector)
		aim_vector = aim_vector.rotated(PI / 4)
	else:
		var target: Node2D = actor.select_target()
		await pattern.shoot(actor, battle, (target.global_position - actor.global_position).normalized())
	is_shooting = false
