class_name Unit extends Node2D

var squad: Squad

func _ready():
	squad = get_parent()
	squad.unit_count += 1
	$health.on_death.connect(func(): squad.on_unit_died(self))
