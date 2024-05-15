class_name Battle extends Node2D

enum Faction {Neutral, Ally, Enemy}

var on_going := false

const STARTING_POS: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(400, 0),
	Vector2(-400, 0),
]

@export var player_scene: PackedScene
@export var squad_scene: PackedScene
@export var enemy_scene: PackedScene

var squads_info: Array[UM.Squad]
var squad_list: Array[SquadController] = []
var enemy_list: Array[Node2D] = []

func _ready():
	visible = false
	add_child(player_scene.instantiate())
	player().enabled = false

func start_battle(squads: Array[UM.Squad]):
	on_going = true
	
	squads_info = squads
	squad_list.clear()
	visible = true
	
	await get_tree().process_frame
	
	add_decor()
	add_enemy(Vector2(0, -200))
	add_child(player_scene.instantiate())
	for i in squads.size():
		add_squad(squads[i], STARTING_POS[i])

func add_squad(squad_info: UM.Squad, pos: Vector2):
	var squad: SquadController = squad_scene.instantiate()
	add_child(squad)
	squad.position = pos
	squad_list.append(squad)
	for unit in squad_info.units:
		squad.create_unit(unit)
	
func add_enemy(pos):
	var new_enemy = enemy_scene.instantiate()
	add_child(new_enemy)
	new_enemy.position = pos
	enemy_list.append(new_enemy)
	new_enemy.get_node("health").on_death.connect(remove_enemy.bind(new_enemy))

func remove_enemy(enemy):
	enemy_list.erase(enemy)
	if enemy_list.is_empty():
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
	
	player().enabled = false
	battle.on_going = false
	map.battle_end_callback()

func add_decor():
	pass
func player() -> Player: return $player as Player
