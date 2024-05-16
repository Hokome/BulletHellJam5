extends PanelContainer
class_name UnitStatUI

@export var stat_scene: PackedScene
@export var stat_list: Control

func display_stats(unit: UM.Unit):
	for c in stat_list.get_children():
		c.free()
	
	for s: UM.UnitStat in unit.stats.values():
		if s.type == UM.StatType.Support: continue
		var stat_ui = stat_scene.instantiate()
		stat_list.add_child(stat_ui)
		stat_ui.find_child("type").text = s.type_to_string() + ": "
		stat_ui.find_child("intensity").text = s.intensity_to_string()
