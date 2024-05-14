extends Node
class_name UM
#Shortened from Unit Manager

var selected_squad: SquadInfo:
	set(val):
		selected_squad = val

var full_squad_dictionary: Dictionary = {}
var next_id: int = 1

func select_squad(id: int):
	selected_squad = full_squad_dictionary[id]

class SquadInfo extends RefCounted:
	var units: Array[UnitInfo] = []
	var id: int
	var name: String
	var pos_locked := false
	var marked_delete := false

class UnitInfo extends RefCounted:
	var name: String
	var hp: int
	var max_hp: int
	var marked_delete := false

func create_squad() -> SquadInfo:
	var squad: SquadInfo = SquadInfo.new()
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

func add_unit(squad: SquadInfo, unit_name: String):
	var unit := UnitInfo.new()
	unit.name = unit_name
	unit.max_hp = 5
	unit.hp = unit.max_hp
	squad.units.append(unit)
