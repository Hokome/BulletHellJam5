class_name Squad extends Area2D

@export var speed: float
@export var test_unit: PackedScene

var hovered := false
var selected := false

var unit_count: int = 0

func create_units():
	create_unit(Vector2(100, 0))
	create_unit(Vector2(-100, 0))

func create_unit(pos):
	var anchor = Node2D.new()
	add_child(anchor)
	anchor.position = pos
	anchor.name = "anchor"
	
	var unit = test_unit.instantiate()
	get_parent().add_child(unit)
	unit.global_position = anchor.global_position
	
	unit_count += 1
	unit.squad = self
	unit.anchor = anchor
	unit.get_node("health").on_death.connect(on_unit_died)

func on_unit_died():
	unit_count -= 1
	if unit_count <= 0:
		queue_free()

func _on_mouse_entered():
	hovered = true
	battle.player().hovered_squad = self

func _on_mouse_exited():
	hovered = false
	battle.player().hovered_squad = null
