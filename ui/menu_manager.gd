extends CanvasLayer

var current_menu: String = ""

func select_menu(menu: String):
	if !current_menu.is_empty():
		get_node(current_menu).visible = false
	current_menu = menu
	
	if !current_menu.is_empty():
		get_node(current_menu).visible = true

func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.physical_keycode == KEY_ESCAPE:
			if current_menu.is_empty():
				select_menu("pause_menu")
				time_manager.paused = true
