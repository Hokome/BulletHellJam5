class_name Battle extends Node2D

enum Faction {Neutral, Ally, Enemy}

const STARTING_POS: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(400, 0),
	Vector2(-400, 0),
]

@export var player_scene: PackedScene
@export var squad_scene: PackedScene
@export var enemy: PackedScene

var squad_list: Array[Squad] = []
var enemy_list: Array[Node2D] = []

func _ready():
	visible = false
	var player = player_scene.instantiate()
	player.enabled = false

func start_battle(squads: Array[Map.SquadInfo]):
	visible = true
	add_enemy(Vector2(0, -200))
	add_child(player_scene.instantiate())
	for i in squads.size():
		add_squad(squads[i], STARTING_POS[i])

func add_enemy(pos):
	var new_enemy = enemy.instantiate()
	add_child(new_enemy)
	new_enemy.position = pos
	enemy_list.append(new_enemy)
	new_enemy.get_node("health").on_death.connect(remove_enemy.bind(new_enemy))

func remove_enemy(enemy):
	enemy_list.erase(enemy)
	if enemy_list.is_empty():
		end_battle()

func end_battle():
	for c in get_children():
		if c.name != "player":
			c.queue_free()
	player().enabled = false
	map.battle_end_callback()
func add_squad(squad_info: Map.SquadInfo, pos: Vector2):
	var squad: Squad = squad_scene.instantiate()
	add_child(squad)
	squad.position = pos
	for unit in squad_info.units:
		squad.create_unit(unit)

func player() -> Player: return $player as Player
