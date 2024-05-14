class_name Squad extends Area2D

signal anchor_changed
signal target_in_range

@export var speed: float
@export var test_unit: PackedScene

var hovered := false
var selected := false

var units: Array[Unit] = []

const UNIT_POS: Array[Vector2] = [
	Vector2(100, 0),
	Vector2(-100, 0),
]

func create_unit(unit_info: UM.UnitInfo):
	var pos = UNIT_POS[units.size()]
	var anchor = Node2D.new()
	add_child(anchor)
	anchor.position = pos
	anchor.name = "anchor"
	
	var unit: Unit = test_unit.instantiate()
	get_parent().add_child(unit)
	unit.global_position = anchor.global_position
	unit.import_unit(unit_info)
	
	units.append(unit)
	
	unit.squad = self
	unit.get_node("health").on_death.connect(on_unit_died.bind(unit))
	
	anchor_changed.connect(unit.reposition.bind(anchor))

func update_units():
	for u in units:
		u.update_unit_info()

func on_unit_died(unit):
	anchor_changed.disconnect(unit.reposition)
	units.erase(unit)
	
	if units.is_empty():
		queue_free()

func _on_mouse_entered():
	hovered = true
	battle.player().hovered_squad = self

func _on_mouse_exited():
	hovered = false
	battle.player().hovered_squad = null
