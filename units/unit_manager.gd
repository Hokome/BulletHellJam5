extends Node
class_name UM
#Shortened from Unit Manager

var selected_squad: Squad:
	set(val):
		selected_squad = val

var selected_unit: Unit:
	set(val):
		selected_unit = val

var full_squad_dictionary: Dictionary = {}
var next_id: int = 1

func select_squad(id: int):
	selected_squad = full_squad_dictionary[id]

class Squad extends RefCounted:
	var units: Array[Unit] = []
	var id: int
	var name: String
	var pos_locked := false
	var marked_delete := false
	
	func add_unit(unit: Unit):
		unit.squad = self
		units.append(unit)
	
	func remove_unit(unit: Unit):
		unit.squad = null
		units.erase(unit)
		if units.is_empty():
			marked_delete = true

class Unit extends RefCounted:
	var name: String
	var hp: int
	var max_hp: int
	var squad: Squad
	
	var marked_delete := false
	
	func remove_from_squad():
		squad.remove_unit(self)

func create_squad() -> Squad:
	var squad: Squad = Squad.new()
	full_squad_dictionary[next_id] = squad
	squad.id = next_id
	next_id += 1
	
	squad.name = "Squad %s" % squad.id
	
	return squad

func add_squads():
	var tile: Map.Tile = map.tiles[6][6]
	tile.add_squad(create_squad())
	tile.add_squad(create_squad())
	
	add_unit(tile.squads[0], "John")
	add_unit(tile.squads[0], "Kevin")
	add_unit(tile.squads[1], "Bob")

func add_unit(squad: Squad, unit_name: String):
	var unit := Unit.new()
	unit.name = unit_name
	unit.max_hp = 5
	unit.hp = unit.max_hp
	squad.add_unit(unit)
