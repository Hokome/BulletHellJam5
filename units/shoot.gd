extends ActionLeaf

@export var pattern: ProjectilePattern

var is_shooting := false
var started_shooting := false

func before_run(actor: Node, blackboard: Blackboard):
	started_shooting = false

func tick(actor: Node, blackboard: Blackboard) -> int:
	print("shoot")
	if !started_shooting:
		shoot_async(actor)
	if !is_shooting: return SUCCESS
	
	return RUNNING

func shoot_async(actor: Node2D):
	is_shooting = true
	started_shooting = true
	
	var target: Node2D = actor.select_target()
	await pattern.shoot(actor, battle, (target.global_position - actor.global_position).normalized())
	is_shooting = false
