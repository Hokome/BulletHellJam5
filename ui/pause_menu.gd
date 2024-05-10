extends PanelContainer

func resume():
	time_manager.paused = false
	
	menus.select_menu("")

func exit():
	get_tree().quit()
