class_name MapUI extends CanvasLayer

@export var squad_ui_scene: PackedScene
@export var unit_ui_scene: PackedScene
@onready var squad_list = $right/vbox/squads
@onready var edit_button = $right/vbox/edit

var is_editing := false:
	set(val):
		is_editing = val
		for s: SquadUI in squad_list.get_children():
			s.select_button.visible = !is_editing
			s.empty_spot_button.visible = is_editing

func _ready():
	display_squads([])
	edit_button.pressed.connect(toggle_edit)

func toggle_edit(): is_editing = !is_editing

func display_squads(squads: Array):
	edit_button.visible = !squads.is_empty()
	
	for c in squad_list.get_children():
		c.queue_free()
	
	for squad_info: UM.Squad in squads:
		var squad_ui: SquadUI = squad_ui_scene.instantiate()
		squad_list.add_child(squad_ui)
		squad_ui.name_label.text = squad_info.name
		
		for unit_info in squad_info.units:
			var unit_ui: UnitUI = unit_ui_scene.instantiate()
			squad_ui.unit_list.add_child(unit_ui)
			unit_ui.name_label.text = unit_info.name
			unit_ui.hp_bar.max_value = unit_info.max_hp
			unit_ui.hp_bar.value = unit_info.hp
		
		squad_ui.sort_children()
		
		squad_ui.select_button.pressed.connect(um.select_squad.bind(squad_info.id))
