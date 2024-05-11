class_name Health extends Node2D

signal on_death()

var value: int:
	set(val):
		value = min(max_value, val)
		if value <= 0:
			kill()
var max_value: int

func kill():
	on_death.emit()
	get_parent().queue_free()

func damage(amount):
	value -= amount
