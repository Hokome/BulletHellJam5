class_name Map extends Node2D

@export var squad_texture: Texture

const MAP_SIZE: int = 12
const HALF_MAP: int = MAP_SIZE / 2

const TILE_SIZE: int = 512
const HALF_TILE: int = TILE_SIZE / 2

@onready var cursor: Node2D = $cursor

class Tile:
	var position: Vector2i
	var type: int = -1
	var squads: Array[SquadInfo] = []
	var map_icon: Sprite2D

class SquadInfo:
	var units: Array[UnitInfo] = []

class UnitInfo:
	var name: String

@onready var map_ui = $map_ui

var tiles := []
var selected_tile: Tile:
	set(val):
		selected_tile = val
		map_ui.display_squads(selected_tile.squads)

func _ready():
	generate_map()
	add_squads()
	$map_camera.translate(Vector2.ONE * TILE_SIZE * HALF_MAP)

func add_squads():
	var tile: Tile = tiles[6][6]
	tile.squads = [SquadInfo.new()]
	
	tile.map_icon = Sprite2D.new()
	tile.map_icon.texture = squad_texture
	add_child(tile.map_icon)
	tile.map_icon.position = grid_to_world(tile.position)
	
	add_unit(tile.squads[0], "John")
	add_unit(tile.squads[0], "Kevin")

func add_unit(squad: SquadInfo, unit_name: String):
	var unit := UnitInfo.new()
	unit.name = unit_name
	squad.units.append(unit)

func generate_map():
	var tile_map: TileMap = $tiles
	for x in MAP_SIZE:
		tiles.append([])
		for y in MAP_SIZE:
			var tile = Tile.new()
			tile.type = 0
			tile.position = Vector2i(x, y)
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
			tiles[x].append(tile)

func _process(delta):
	cursor.position = get_cursor_world()

func grid_to_world(grid_pos: Vector2i) -> Vector2: return (grid_pos as Vector2) * TILE_SIZE - Vector2.ONE * HALF_TILE

func get_cursor_world() -> Vector2:
	var cursor_pos = get_local_mouse_position()
	return cursor_pos - cursor_pos.posmod(TILE_SIZE) + Vector2.ONE * HALF_TILE

func get_cursor_grid() -> Vector2i: return (get_cursor_world() / TILE_SIZE).round()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var select_pos := get_cursor_grid()
			selected_tile = tiles[select_pos.x][select_pos.y]
