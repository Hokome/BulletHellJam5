class_name Unit extends CharacterBody2D

@export var speed: float

var squad: Squad
var target_position: Vector2
var is_repositioning: bool

func _physics_process(delta):
	if is_repositioning:
		if is_at_destination(delta):
			is_repositioning = false
			global_position = target_position
			velocity = Vector2.ZERO
		else:
			var diff = (target_position - global_position)
			velocity = diff.normalized() * speed
			move_and_slide()

func is_at_destination(delta) -> bool: return (target_position - global_position).length() <= speed * delta

func reposition(pos):
	is_repositioning = true
	if pos is Vector2:
		target_position = pos
	else:
		target_position = pos.global_position
