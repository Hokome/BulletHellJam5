extends State

@export var min_anchor_dist: float

@onready var unit: Unit = get_parent().get_parent()

func update(_delta):
	if is_at_destination():
		state_machine.set_state("idle")
	else:
		var diff = (unit.anchor.global_position - unit.global_position)
		unit.velocity = diff.normalized() * unit.speed

func on_exit():
		unit.velocity = Vector2.ZERO

func is_at_destination() -> bool: return (unit.anchor.global_position - unit.global_position).length() <= min_anchor_dist
