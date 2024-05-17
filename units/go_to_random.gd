extends ActionLeaf

@export var selection_range = Vector2.ONE * 100
var point: Vector2

func before_run(actor: Node, blackboard: Blackboard):
	point = Vector2(randf_range(-selection_range.x, selection_range.x), randf_range(-selection_range.y, selection_range.y))

func tick(actor: Node, blackboard: Blackboard) -> int:
	if not actor is Node2D: return FAILURE
	
	var diff: Vector2 = point - actor.global_position
	var dist := diff.length()
	if dist <= actor.speed * get_physics_process_delta_time():
		return SUCCESS
	
	# Dividing by distance instead of calling expensive normalized() function
	var vel: Vector2 = diff * actor.speed / dist
	
	if actor is CharacterBody2D:
		vel = vel.limit_length(dist / get_physics_process_delta_time())
		actor.velocity = vel
	else:
		vel *= get_physics_process_delta_time()
		vel = vel.limit_length(dist)
		actor.global_position += vel
	
	return RUNNING
