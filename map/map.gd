class_name Map extends Node2D

@export var squad_texture: Texture

const MAP_SIZE: int = 12
@warning_ignore("integer_division")
const HALF_MAP: int = MAP_SIZE / 2

const TILE_SIZE: int = 512
@warning_ignore("integer_division")
const HALF_TILE: int = TILE_SIZE / 2

@onready var cursor: Node2D = $cursor

class Tile:
	var position: Vector2i
	var type: int = -1
	var squads: Array[UM.SquadInfo] = []
	var map_icon: Sprite2D
	var resolved := false
	
	func reset():
		resolved = false
		for s in squads:
			s.pos_locked = false
			for u in s.units:
				if u.marked_delete:
					s.units.erase(u)
		for s in squads:
			if s.marked_delete:
				squads.erase(s)
	
	func add_squad(squad: UM.SquadInfo):
		squads.append(squad)
		if squads.size() != 1: return
			
		map_icon = Sprite2D.new()
		map_icon.texture = map.squad_texture
		map.add_child(map_icon)
		map_icon.position = map.grid_to_world(position)
	
	func remove_squad(squad: UM.SquadInfo):
		squads.erase(squad)
		
		if !squads.is_empty(): return
		
		map_icon.queue_free()



@onready var map_ui = $map_ui

var tiles := []
var selected_tile: Tile:
	set(val):
		selected_tile = val
		um.selected_squad = null
		if selected_tile != null:
			map_ui.display_squads(selected_tile.squads)
		else:
			map_ui.display_squads([])

func _ready():
	generate_map()
	$map_camera.translate(Vector2.ONE * TILE_SIZE * HALF_MAP)
	
	um.add_squads()

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

func move_squad(squad: UM.SquadInfo, from: Tile, to: Tile):
	var diff := to.position - from.position
	if (diff as Vector2).length_squared() > 1.1: return
	
	if squad.pos_locked: return
	
	from.remove_squad(squad)
	to.add_squad(squad)
	squad.pos_locked = true
	
	map_ui.display_squads(to.squads)

func _process(_delta):
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
			if selected_tile != null and um.selected_squad != null:
				var select_pos := get_cursor_grid()
				var destination_tile = tiles[select_pos.x][select_pos.y]
				move_squad(um.selected_squad, selected_tile, destination_tile)

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
	selected_tile = null
