class_name MapUI extends CanvasLayer

@export var squad_ui: PackedScene
@export var unit_ui: PackedScene

func display_squads(squad_list: Array):
	var squads = $right/squads
	for c in squads.get_children():
		c.queue_free()
	
	for squad_info: UM.SquadInfo in squad_list:
		var sq_ui := squad_ui.instantiate()
		squads.add_child(sq_ui)
		sq_ui.get_node("margin/vbox/name").text = squad_info.name
		
		var units = sq_ui.get_node("margin/vbox/units")
		for unit_info in squad_info.units:
			var u_ui: UnitUI = unit_ui.instantiate()
			units.add_child(u_ui)
			u_ui.name_label.text = unit_info.name
			u_ui.hp_bar.max_value = unit_info.max_hp
			u_ui.hp_bar.value = unit_info.hp
		
		sq_ui.get_node("select").pressed.connect(um.select_squad.bind(squad_info.id))
