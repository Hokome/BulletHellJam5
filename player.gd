class_name Player extends Camera2D

var hovered_squad: Squad
var selected_squad: Squad

func _process(_delta):
	if time_manager.paused: return
	
	if Input.is_action_just_pressed("select_squad"):
		selected_squad = hovered_squad
	
	if selected_squad != null and Input.is_action_just_pressed("squad_action"):
		selected_squad.position = get_local_mouse_position()
