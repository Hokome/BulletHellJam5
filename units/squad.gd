class_name Squad extends CharacterBody2D

@export var speed: float
@export var min_target_dist: float

@onready var direction_line = $direction_line

var hovered := false
var selected := false

var target_position: Vector2

var unit_count: int = 0

func _process(_delta):
	if time_manager.paused: return
	direction_line.visible = not is_at_destination()
	direction_line.points[1] = target_position - position

func _physics_process(delta):
	if time_manager.paused: return
	if not is_at_destination():
		var diff = (target_position - position)
		velocity = diff.normalized() * speed
		move_and_slide()

func is_at_destination() -> bool: return (target_position - position).length() <= min_target_dist

func on_unit_died(unit):
	unit_count -= 1
	if unit_count <= 0:
		queue_free()

func _on_mouse_entered():
	hovered = true
	battle.player().hovered_squad = self

func _on_mouse_exited():
	hovered = false
	battle.player().hovered_squad = null
