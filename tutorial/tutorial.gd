extends PanelContainer

@export var tutorial_list : Array[Texture]
var tutorial_index := 0
@onready var tutorial_rect = $margin_container/v_box_container/texture_rect
#multiple layouts? do export variable "tutorial_image" or tutorial image REKT
# on ready variable @onready
#Array[] means Array OF something. texture, var whatever idk man

func _on_previous_pressed():
	tutorial_index = max(0, tutorial_index - 1)
	tutorial_rect.texture = tutorial_list[tutorial_index]
	pass # Replace with function body.


func _on_next_pressed():
	tutorial_index = min(tutorial_list.size() - 1, tutorial_index + 1)
	tutorial_rect.texture = tutorial_list[tutorial_index]
	pass # Replace with function body.

func _ready():
	tutorial_rect.texture = tutorial_list[tutorial_index]
	

