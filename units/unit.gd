class_name Unit extends CharacterBody2D

@export var speed: float
@export var min_anchor_dist: float

var squad: Squad
var anchor: Node2D

func _process(delta):
	if not is_at_destination():
		var diff = (anchor.global_position - global_position)
		velocity = diff.normalized() * speed
		move_and_slide()

func is_at_destination() -> bool: return (anchor.global_position - global_position).length() <= min_anchor_dist
