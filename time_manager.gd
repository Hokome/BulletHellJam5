class_name TimeManager extends Node

signal on_pause_toggled()
signal on_paused()
signal on_resumed()

var paused := false:
	set(value):
		if value == paused: return
		paused = value
		Engine.time_scale = 0 if paused else 1
		
		on_pause_toggled.emit(value)
		if value:
			on_paused.emit()
		else:
			on_resumed.emit()

var can_pause_game := false

var time_scale := 1.0

func create_timer(time: float, one_shot: bool = true, autostart: bool = true) -> BattleTimer:
	var timer = BattleTimer.new()
	timer.wait_time = time
	timer.one_shot = one_shot
	timer.autostart = autostart
	
	timer.setup()
	
	return timer
