class_name MapUI extends CanvasLayer

signal confirm_button_pressed()

@export var squad_ui_scene: PackedScene
@export var unit_ui_scene: PackedScene
@onready var squad_list = $right/vbox/squads
@onready var edit_button = $right/vbox/edit
@onready var new_squad_button = $right/vbox/new_squad

var elem_dictionary: Dictionary = {}

var is_editing := false:
	set(val):
		is_editing = val
		new_squad_button.visible = is_editing
		
		for s: SquadUI in squad_list.get_children():
			s.select_button.visible = !is_editing
			s.empty_spot_button.visible = is_editing

func _ready():
	display_squads([])
	edit_button.pressed.connect(toggle_edit)
	$bottom_left/confirm_button.pressed.connect(emit_signal.bind(confirm_button_pressed.get_name()))

func toggle_edit(): is_editing = !is_editing

func display_squads(squads: Array):
	elem_dictionary.clear()
	
	is_editing = false
	for c in squad_list.get_children():
		c.queue_free()
	
	if squads.is_empty():
		edit_button.visible = false
		return
	
	edit_button.visible = true
	
	for squad_info: UM.Squad in squads:
		var squad_ui: SquadUI = create_squad_ui(squad_info)
		
		for unit_info in squad_info.units:
			var unit_ui: UnitUI = unit_ui_scene.instantiate()
			squad_ui.unit_list.add_child(unit_ui)
			
			unit_ui.assign_unit(unit_info)
			
			unit_ui.select_button.pressed.connect(unit_clicked.bind(unit_info))
			elem_dictionary[unit_info] = unit_ui
		
		squad_ui.sort_children()

func create_squad_ui(squad_info: UM.Squad) -> SquadUI:
	var squad_ui: SquadUI = squad_ui_scene.instantiate()
	squad_list.add_child(squad_ui)
	
	squad_ui.name_label.text = squad_info.name
	squad_ui.empty_spot_button.pressed.connect(move_to_squad.bind(squad_info))
	elem_dictionary[squad_info] = squad_ui
	
	squad_ui.select_button.pressed.connect(um.select_squad.bind(squad_info.id))
	squad_ui.trash_button.pressed.connect(on_trash_button_pressed.bind(squad_info))
	
	squad_ui.empty_spot_button.visible = is_editing
	squad_ui.trash_button.visible = is_editing and squad_info.marked_delete
	
	return squad_ui

func unit_clicked(unit: UM.Unit):
	if !is_editing: return
	
	um.selected_unit = unit

func move_to_squad(squad: UM.Squad):
	if !is_editing: return
	if squad == null: return
	if um.selected_unit == null: return
	
	var old_squad = um.selected_unit.squad
	um.selected_unit.remove_from_squad()
	squad.add_unit(um.selected_unit)
	
	var unit_ui = elem_dictionary[um.selected_unit]
	var squad_ui = elem_dictionary[squad]
	
	unit_ui.reparent(squad_ui.unit_list)
	squad_ui.sort_children()
	squad_ui.trash_button.visible = false
	
	var old_ui = elem_dictionary[old_squad]
	old_ui.trash_button.visible = old_squad.marked_delete

func on_trash_button_pressed(squad: UM.Squad):
	map.selected_tile.remove_squad(squad)
	elem_dictionary[squad].queue_free()

func _on_new_squad_pressed():
	var squad: UM.Squad = um.create_squad()
	map.selected_tile.add_squad(squad)

	create_squad_ui(squad)
