extends Control
class_name SquadUI

@export var name_label: Label
@export var select_button: Button
@export var unit_list: Control
@export var empty_spot_button: Button

func sort_children():
	var last_index := get_child_count() - 1
	if empty_spot_button.get_index() != last_index:
		remove_child(empty_spot_button)
		add_child(empty_spot_button)
