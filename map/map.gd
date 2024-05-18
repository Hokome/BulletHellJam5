class_name Map extends Node2D

@export var squad_texture: Texture


const MAP_SIZE: Vector2i = Vector2i(6, 4)
@warning_ignore("integer_division")
const HALF_MAP: Vector2i = MAP_SIZE / 2

const TILE_SIZE: int = 512
@warning_ignore("integer_division")
const HALF_TILE: int = TILE_SIZE / 2

@onready var cursor: Node2D = $cursor

var fully_resolved := true
var is_selecting_new_unit := false:
	set(val):
		is_selecting_new_unit = val
		map_ui.confirm_button.visible = !val

class Tile:
	var position: Vector2i
	var type: int = -1
	var squads: Array[UM.Squad] = []
	var map_icon: Sprite2D
	var resolved := false
	
	func reset():
		resolved = false
		cleanup_squads()
	
	func cleanup_squads():
		for s in squads:
			s.pos_locked = false
			for u in s.units:
				if u.marked_delete:
					s.units.erase(u)
			if s.units.is_empty():
				s.marked_delete = true
			
		for s in squads:
			if s.marked_delete:
				remove_squad(s)
	
	func add_squad(squad: UM.Squad):
		squads.append(squad)
		if squads.size() != 1: return
			
		map_icon = Sprite2D.new()
		map_icon.texture = map.squad_texture
		map.add_child(map_icon)
		map_icon.position = map.grid_to_world(position)
	
	func remove_squad(squad: UM.Squad):
		squads.erase(squad)
		
		if !squads.is_empty(): return
		
		map_icon.queue_free()

@onready var map_ui: MapUI = $map_ui

var tiles := []
var selected_tile: Tile:
	set(val):
		if is_selecting_new_unit: return
		selected_tile = val
		
		map_ui.is_editing = false
		um.selected_unit = null
		um.selected_squad = null
		
		if selected_tile != null and not is_selecting_new_unit:
			map_ui.display_squads(selected_tile.squads)
		else:
			map_ui.display_squads([])

func get_tile(pos: Vector2i) -> Tile:
	if pos.x < 0 or pos.y < 0: return null
	if pos.x >= MAP_SIZE.x or pos.y >= MAP_SIZE.y: return null
	return tiles[pos.x][pos.y]

func _ready():
	generate_map()
	$map_camera.translate(TILE_SIZE * HALF_MAP)
	var starter_tile: Tile = get_tile(Vector2(0, 1))
	map.selected_tile = starter_tile
	is_selecting_new_unit = true
	
	for i in 3:
		var starter_units: Array[UM.Unit] = [um.create_random_unit(), um.create_random_unit(), um.create_random_unit()]
			
		map_ui.display_new_units(starter_units)
		
		await map_ui.on_new_unit_selected
	
	is_selecting_new_unit = false
	selected_tile = starter_tile


func generate_map():
	var tile_map: TileMap = $tiles
	for x in MAP_SIZE.x:
		tiles.append([])
		for y in MAP_SIZE.y:
			var tile = Tile.new()
			tile.type = 0
			tile.position = Vector2i(x, y)
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
			tiles[x].append(tile)

func move_squad(squad: UM.Squad, from: Tile, to: Tile):
	if to == null: return
	var diff := to.position - from.position
	var length = (diff as Vector2).length_squared()
	if length > 1 or length == 0: return
	
	if squad.pos_locked: return
	
	from.remove_squad(squad)
	to.add_squad(squad)
	squad.pos_locked = true
	
	map_ui.display_squads(to.squads)

func _process(_delta):
	cursor.position = get_cursor_world()

func grid_to_world(grid_pos: Vector2i) -> Vector2: return (grid_pos as Vector2) * TILE_SIZE + Vector2.ONE * HALF_TILE

func snap_to_grid(world_pos: Vector2) -> Vector2: return world_pos - world_pos.posmod(TILE_SIZE) + Vector2.ONE * HALF_TILE

func world_to_grid(world_pos: Vector2) -> Vector2i: return Vector2i(world_pos - world_pos.posmod(TILE_SIZE)) / TILE_SIZE

func get_cursor_world() -> Vector2: return snap_to_grid(get_local_mouse_position())

func get_cursor_grid() -> Vector2i: return world_to_grid(get_local_mouse_position())

func _unhandled_input(event):
	if !visible: return
	if event is InputEventMouseButton:
		if !event.is_pressed(): return
		if event.button_index == MOUSE_BUTTON_LEFT:
			var select_pos := get_cursor_grid()
			selected_tile = get_tile(select_pos)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if selected_tile != null and um.selected_squad != null:
				var select_pos := get_cursor_grid()
				var destination_tile = get_tile(select_pos)
				move_squad(um.selected_squad, selected_tile, destination_tile)

func battle_end_callback():
	if fully_resolved: return
	if battle.on_going: return
	
	for tx in tiles:
		for ty: Tile in tx:
			if ty.resolved: continue
			if !ty.squads.is_empty():
				ty.resolved = true
				ty.cleanup_squads()
				battle.start_battle.call_deferred(ty.squads, (ty.position.x) * 2)
				return
			ty.resolved = true
	
	visible = true
	map_ui.visible = true
	for tx in tiles:
		for ty: Tile in tx:
			ty.reset()
	
	$map_camera.enabled = true
	selected_tile = null
	fully_resolved = true

func _on_confirm_pressed():
	fully_resolved = false
	visible = false
	map_ui.visible = false
	$map_camera.enabled = false
	battle_end_callback()
