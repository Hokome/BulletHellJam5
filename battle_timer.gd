class_name BattleTimer extends Timer

func setup():
	paused = time_manager.paused
	time_manager.on_pause_toggled.connect(set_paused)

func _exit_tree():
	time_manager.on_pause_toggled.disconnect(set_paused)
