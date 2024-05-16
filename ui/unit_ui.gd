extends Control
class_name UnitUI

@export var name_label: Label
@export var hp_bar: ProgressBar
@export var hair_image: TextureRect
@export var stat_ui: UnitStatUI

@export var select_button: Button

func assign_unit(unit: UM.Unit):
	name_label.text = unit.name
	
	if hair_image:
		hair_image.modulate = unit.hair_color
		var path = unit.hair_style.resource_path.trim_suffix("_frames.tres") + ".png"
		var atlas := hair_image.texture as AtlasTexture
		atlas = atlas.duplicate()
		atlas.atlas = load(path)
		hair_image.texture = atlas
	
	if hp_bar:
		hp_bar.max_value = unit.get_max_hp()
		hp_bar.value = unit.hp
	
	if stat_ui:
		stat_ui.display_stats(unit)
