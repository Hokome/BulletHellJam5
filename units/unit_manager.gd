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
		marked_delete = false
	
	func remove_unit(unit: Unit):
		unit.squad = null
		units.erase(unit)
		if units.is_empty():
			marked_delete = true

const UNIT_NAMES = [
	"John",
	"Bob",
	"Kevin",
	"Lito",
	"Hugo",
	"Hans",
	"William",
	"Albert",
	"Cyril",
	"Charles",
	"Vincent",
	"Leo",
	"Juan",
	"Julian",
	"Milo",
]
const FEMININE_NAMES = [
	"Maria",
	"Karen",
	"Emily",
	"Laura",
	"Elise",
	"Sarah",
	"Angela",
	"Cecile",
	"Claire",
	"Lucie",
	"Rebecca",
	"Robin",
	"Daniela",
	"Luana",
]

class Unit extends RefCounted:
	var name: String
	var hp: int
	var max_hp: int
	var squad: Squad
	
	var marked_delete := false
	
	func remove_from_squad():
		squad.remove_unit(self)
	
	static func create_random() -> Unit:
		var unit := Unit.new()
		unit.name = FEMININE_NAMES.pick_random()
		unit.max_hp = 5
		unit.hp = unit.max_hp
		
		return unit

func create_squad() -> Squad:
	var squad: Squad = Squad.new()
	full_squad_dictionary[next_id] = squad
	squad.id = next_id
	next_id += 1
	
	squad.name = "Squad %s" % squad.id
	squad.marked_delete = true
	
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
