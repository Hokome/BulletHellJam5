class_name Health extends Node2D

signal on_death()

@export var ui: ProgressBar
@export var max_value: int

var value: int:
	set(val):
		value = min(max_value, val)
		if ui:
			ui.value = value
		if value <= 0:
			kill()

func _ready():
	if ui:
		ui.max_value = max_value
	
	if value == 0:
		value = max_value
	

func kill():
	on_death.emit()
	get_parent().queue_free()

func damage(amount: int):
	value -= amount
