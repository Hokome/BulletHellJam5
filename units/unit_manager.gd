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

const MASCULINE_NAMES = [
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

@export var hair_colors: PackedColorArray
@export var hair_styles: Array[SpriteFrames]

enum StatIntensity {None = 0, Low = 1, Med = 2, High = 3}
enum StatType {None, Vitality, Damage,}

const STAT_BOUNDS = {
	StatType.Vitality:
		{
			StatIntensity.Low: [10, 15],
			StatIntensity.Med: [20, 30],
			StatIntensity.High: [35, 50],
		},
	StatType.Damage:
		{
			StatIntensity.Low: [0.6, 0.8],
			StatIntensity.Med: [1, 1.2],
			StatIntensity.High: [1.5, 2],
		},
}

class UnitStat:
	var type: StatType = StatType.None
	var intensity: StatIntensity
	var value: float
	
	func generate_precise():
		var bounds = STAT_BOUNDS[type][intensity]
		value = randf_range(bounds[0], bounds[1])
		
		if type == StatType.Vitality:
			value = roundf(value)
	
	func type_to_string() -> String:
		var type_s: String = "None"
		match type:
			StatType.Vitality:
				type_s = "Vitality"
			StatType.Damage:
				type_s = "Damage"
		return type_s
	
	func intensity_to_string() -> String:
		var intensity_s: String = "None"
		match intensity:
			StatIntensity.Low:
				intensity_s = "Low"
			StatIntensity.Med:
				intensity_s = "Med"
			StatIntensity.High:
				intensity_s = "High"
		return intensity_s

	func _to_string():
		var type_s: String = type_to_string()
		var intensity_s: String = intensity_to_string()
		
		return "%s: %s (%s)" % [type_s, intensity_s, value]

class Unit extends RefCounted:
	var name: String
	var hp: int
	
	var stats: Dictionary = {}
	
	var hair_style: SpriteFrames
	var hair_color: Color
	
	var squad: Squad
	var marked_delete := false:
		set(val):
			marked_delete = val
	
	func remove_from_squad():
		squad.remove_unit(self)
	
	func get_max_hp() -> float:
		return stats[StatType.Vitality].value
	func get_damage() -> float:
		return stats[StatType.Damage].value
	
	func create_stat(type: StatType, initial: StatIntensity = StatIntensity.Low):
		var stat := UnitStat.new()
		stat.type = type
		stat.intensity = initial
		stats[type] = stat
	
	func increment_stat(type: StatType) -> bool:
		var stat: UnitStat = stats[type]
		if stat.intensity == StatIntensity.High: return false
		stat.intensity += 1
		return true
	
	func generate_stats(budget: int):
		create_stat(StatType.Vitality)
		create_stat(StatType.Damage)
		
		while budget: 
			var stat = randi_range(1, 2)
			if increment_stat(stat): budget -= 1
		
		for stat in stats.values():
			stat.generate_precise()

func remove_squad(squad: Squad):
	full_squad_dictionary.erase(squad.id)

func create_random_unit() -> Unit:
		var unit := Unit.new()
		var is_male: bool = randi() % 2;
		if is_male:
			unit.name = MASCULINE_NAMES.pick_random()
		else:
			unit.name = FEMININE_NAMES.pick_random()
		
		@warning_ignore("integer_division")
		var half_style_count := hair_styles.size() / 2
		var hair_style_index = randi_range(0, half_style_count - 1)
		if !is_male:
			hair_style_index += half_style_count
		var hair_color_index = randi_range(0, hair_colors.size() -1)
		unit.hair_style = hair_styles[hair_style_index]
		unit.hair_color = hair_colors[hair_color_index]
		
		unit.generate_stats(2)
		
		unit.hp = unit.get_max_hp()
		
		return unit
func create_squad() -> Squad:
	var squad: Squad = Squad.new()
	full_squad_dictionary[next_id] = squad
	squad.id = next_id
	next_id += 1
	
	squad.name = "Squad %s" % squad.id
	squad.marked_delete = true
	
	return squad

func add_unit(squad: Squad, unit_name: String):
	var unit := Unit.new()
	unit.name = unit_name
	unit.max_hp = 5
	unit.hp = unit.max_hp
	squad.add_unit(unit)

func clear_all():
	full_squad_dictionary.clear()
