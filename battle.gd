class_name Battle extends Node2D

enum Faction {Neutral, Ally, Enemy}

var on_going := false

const ENEMY_POS: Array[Vector2] = [
	Vector2(-400, -200),
	Vector2(400, -200),
]

const STARTING_POS: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(400, 0),
	Vector2(-400, 0),
]

@export var player_scene: PackedScene
@export var squad_scene: PackedScene

@export var oni_scene: PackedScene
@export var golem_scene: PackedScene
@export var boss_scene: PackedScene

var squads_info: Array[UM.Squad]
var squad_list: Array[SquadController] = []
var unit_list: Array[UnitController] = []
var enemy_list: Array[Node2D] = []

func _ready():
	visible = false
	add_child(player_scene.instantiate())
	player().enabled = false

func start_battle(squads: Array[UM.Squad], difficulty: int):
	on_going = true
	
	squads_info = squads
	squad_list.clear()
	unit_list.clear()
	visible = true
	
	await get_tree().process_frame
	
	add_decor()
	create_enemies(difficulty)
	
	add_child(player_scene.instantiate())
	for i in squads.size():
		add_squad(squads[i], STARTING_POS[i])

func create_enemies(difficulty: int):
	if difficulty >= 50:
		add_enemy(boss_scene, Vector2.ZERO)
		difficulty -= 50
	while difficulty > 0:
		var pos: Vector2
		while pos.length() < 500:
			pos = get_enemy_pos()
		
		var enemy := randi_range(0, 1)
		if enemy == 0 or difficulty < 2:
			add_enemy(oni_scene, pos)
			difficulty -= 1
		else:
			add_enemy(golem_scene, pos)
			difficulty -= 2

func get_enemy_pos() -> Vector2:
	const bound_x := 1000
	const bound_y := 800
	return Vector2(randf_range(-bound_x, bound_x), randf_range(-bound_y, bound_y))

func add_squad(squad_info: UM.Squad, pos: Vector2):
	pos += Vector2.DOWN * 500
	
	var squad: SquadController = squad_scene.instantiate()
	add_child(squad)
	squad.position = pos
	squad_list.append(squad)
	for unit in squad_info.units:
		squad.create_unit(unit)
	
func add_enemy(enemy_scene: PackedScene, pos: Vector2):
	var new_enemy = enemy_scene.instantiate()
	add_child(new_enemy)
	new_enemy.position = pos
	enemy_list.append(new_enemy)
	new_enemy.get_node("health").on_death.connect(remove_enemy.bind(new_enemy))

func remove_enemy(enemy):
	enemy.get_node("animation").play("death")
	await enemy.get_node("animation").animation_finished
	enemy_list.erase(enemy)
	enemy.queue_free()
	if enemy_list.is_empty():
		end_battle()

func remove_unit(unit: UnitController):
	unit.unit_info.marked_delete = true
	unit_list.erase(unit)
	if unit_list.is_empty():
		end_battle()

func end_battle():
	for i in squad_list.size():
		if squad_list[i] == null:
			squads_info[i].marked_delete = true
		else:
			squad_list[i].update_units()
	for c in get_children():
		if c.name != "player":
			c.queue_free()
	enemy_list.clear()
	
	player().enabled = false
	battle.on_going = false
	map.battle_end_callback.call_deferred()

func add_decor():
	pass
func player() -> Player: return $player as Player
