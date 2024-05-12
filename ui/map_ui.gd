class_name MapUI extends CanvasLayer

@export var squad_ui: PackedScene
@export var unit_ui: PackedScene


func display_squads(squad_list: Array[Map.SquadInfo]):
	var squads = $right/squads
	for c in squads.get_children():
		c.queue_free()
	
	for squad_info in squad_list:
		var sq_ui := squad_ui.instantiate()
		squads.add_child(sq_ui)
		
		var units = sq_ui.get_node("margin/units")
		for unit_info in squad_info.units:
			var u_ui := unit_ui.instantiate()
			units.add_child(u_ui)
			u_ui.text = unit_info.name
