extends Control
class_name UnitUI

@export var name_label: Label
@export var hp_bar: ProgressBar

@export var select_button: Button

func assign_unit(unit: UM.Unit):
	name_label.text = unit.name
	
	if hp_bar:
		hp_bar.max_value = unit.max_hp
		hp_bar.value = unit.hp
