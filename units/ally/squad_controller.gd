class_name SquadController extends Area2D

signal anchor_changed
signal target_in_range

@export var speed: float
@export var test_unit: PackedScene

var hovered := false
var selected := false

var units: Array[UnitController] = []

const UNIT_POS: Array[Vector2] = [
	Vector2(100, 0),
	Vector2(-100, 0),
	Vector2(0, 100),
	Vector2(0, -100),
]

func create_unit(unit_info: UM.Unit):
	var pos = UNIT_POS[units.size()]
	var anchor = Node2D.new()
	add_child(anchor)
	anchor.position = pos
	anchor.name = "anchor"
	
	var unit: UnitController = test_unit.instantiate()
	get_parent().add_child(unit)
	unit.global_position = anchor.global_position
	unit.import_unit(unit_info)
	
	units.append(unit)
	battle.unit_list.append(unit)
	
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
		battle.squad_list.erase(self)
		queue_free()
	
	battle.remove_unit(unit)

func _on_mouse_entered():
	hovered = true
	battle.player().hovered_squad = self

func _on_mouse_exited():
	hovered = false
	battle.player().hovered_squad = null
