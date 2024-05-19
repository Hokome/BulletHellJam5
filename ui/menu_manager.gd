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

func display_end(win: bool):
	$end_game_screen.visible = true
	var text = "Game over"
	if win: text = "You win!"
	$end_game_screen/margin/vbox/label.text = text

func resume():
	time_manager.paused = false
	
	menus.select_menu("")

func exit():
	get_tree().quit()


func restart():
	pass # Replace with function body.
