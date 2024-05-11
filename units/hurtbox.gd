class_name Hurtbox extends Area2D

@export var faction: Battle.Faction

signal on_damage(amount)

func damage(amount):
	on_damage.emit(amount)
