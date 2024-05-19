extends Button

@export var menu_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(menus.select_menu.bind(menu_name))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
