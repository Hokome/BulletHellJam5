class_name MapUI extends CanvasLayer

signal confirm_button_pressed()
signal on_new_unit_selected()

@export var squad_ui_scene: PackedScene
@export var unit_ui_scene: PackedScene
@export var new_unit_ui_scene: PackedScene

@onready var squad_list = $right/vbox/squads
@onready var new_unit_display = $center/new_unit_display
@onready var new_unit_list = $center/new_unit_display/margin/list

@onready var confirm_button = $bottom_left/confirm_button
@onready var edit_button = $right/vbox/edit
@onready var new_squad_button = $right/vbox/new_squad

@onready var stat_tooltip: UnitStatUI = $stat_tooltip

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

func display_new_units(units: Array[UM.Unit]):
	for u in units:
		var unit_ui: UnitUI = new_unit_ui_scene.instantiate()
		new_unit_list.add_child(unit_ui)
		unit_ui.assign_unit(u)
		
		unit_ui.select_button.pressed.connect(new_unit_selected.bind(u))
	new_unit_display.visible = true

func new_unit_selected(unit: UM.Unit):
	var squad: UM.Squad
	if map.selected_tile.squads.is_empty():
		squad = um.create_squad()
		map.selected_tile.add_squad(squad)
	else:
		squad = map.selected_tile.squads[0]
	
	squad.add_unit(unit)
	
	for c in new_unit_list.get_children():
		c.queue_free()
	new_unit_display.visible = false
	
	on_new_unit_selected.emit()

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
			unit_ui.select_button.mouse_entered.connect(unit_mouse_enter.bind(unit_info, unit_ui))
			unit_ui.select_button.mouse_exited.connect(unit_mouse_exit.bind(unit_info, unit_ui))
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

var hovered_unit_ui: UnitUI

func unit_mouse_enter(unit: UM.Unit, ui: UnitUI):
	stat_tooltip.visible = true
	stat_tooltip.display_stats(unit)
	stat_tooltip.global_position = ui.global_position
	stat_tooltip.global_position += Vector2.LEFT * (stat_tooltip.size.x + 20)
	hovered_unit_ui = ui

func unit_mouse_exit(unit: UM.Unit, ui: UnitUI):
	if hovered_unit_ui != ui: return
	stat_tooltip.visible = false
	hovered_unit_ui = null

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

func display_game_over():
	$center/game_over_panel.visible = true

func on_trash_button_pressed(squad: UM.Squad):
	map.selected_tile.remove_squad(squad)
	elem_dictionary[squad].queue_free()

func _on_new_squad_pressed():
	var squad: UM.Squad = um.create_squad()
	map.selected_tile.add_squad(squad)

	create_squad_ui(squad)


func _on_restart_pressed():
	map.start()
