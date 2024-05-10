extends CanvasLayer

var show_cli := false

func _process(_delta):
	if Input.is_action_just_pressed("debug_console"):
		toggle_cli()

func toggle_cli():
	var cli = $CLI
	
	if show_cli:
		cli.visible = false
	else:
		cli.visible = true
		cli.grab_focus()
	
	show_cli = !show_cli
