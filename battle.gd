class_name Battle extends Node2D

enum Faction {Neutral, Ally, Enemy}

@export var player_scene: PackedScene
@export var squad: PackedScene
@export var enemy: PackedScene

func _ready():
	add_child(player_scene.instantiate())
	add_squad(Vector2(-400, 0))
	add_squad(Vector2(400, 0))
	add_enemy(Vector2(0, -200))

func add_enemy(pos):
	var new_enemy = enemy.instantiate()
	add_child(new_enemy)
	new_enemy.position = pos

func add_squad(pos):
	var new_squad = squad.instantiate()
	add_child(new_squad)
	new_squad.position = pos
	new_squad.create_units()

func player() -> Player: return $player as Player
