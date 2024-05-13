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
	var resolved := false
	
	func reset():
		resolved = false
		for s in squads:
			s.pos_locked = false

class SquadInfo:
	var units: Array[UnitInfo] = []
	var pos_locked := false

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

func move_squads(from: Tile, to: Tile):
	var diff := to.position - from.position
	if (diff as Vector2).length_squared() > 1.1: return
	if from.squads[0].pos_locked: return
	for s in from.squads:
		to.squads.append(s)
		from.squads.erase(s)
		s.pos_locked = true
	
	to.map_icon = from.map_icon
	from.map_icon = null
	to.map_icon.translate(diff * TILE_SIZE)
	selected_tile = to

func _process(delta):
	cursor.position = get_cursor_world()

func grid_to_world(grid_pos: Vector2i) -> Vector2: return (grid_pos as Vector2) * TILE_SIZE - Vector2.ONE * HALF_TILE

func get_cursor_world() -> Vector2:
	var cursor_pos = get_local_mouse_position()
	return cursor_pos - cursor_pos.posmod(TILE_SIZE) + Vector2.ONE * HALF_TILE

func get_cursor_grid() -> Vector2i: return (get_cursor_world() / TILE_SIZE).round()

func _unhandled_input(event):
	if !visible: return
	if event is InputEventMouseButton:
		if !event.is_pressed(): return
		if event.button_index == MOUSE_BUTTON_LEFT:
			var select_pos := get_cursor_grid()
			selected_tile = tiles[select_pos.x][select_pos.y]
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if selected_tile != null and !selected_tile.squads.is_empty():
				var select_pos := get_cursor_grid()
				var destination_tile = tiles[select_pos.x][select_pos.y]
				move_squads(selected_tile, destination_tile)


func _on_end_pressed():
	visible = false
	map_ui.visible = false
	$map_camera.enabled = false
	battle_end_callback()

func battle_end_callback():
	for tx in tiles:
		for ty: Tile in tx:
			if ty.resolved: continue
			if !ty.squads.is_empty():
				battle.start_battle(ty.squads)
				ty.resolved = true
				return
			ty.resolved = true
	visible = true
	map_ui.visible = true
	for tx in tiles:
		for ty: Tile in tx:
			ty.reset()
	$map_camera.enabled = true
