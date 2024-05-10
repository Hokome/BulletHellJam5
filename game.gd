class_name Game extends Node2D

@export var player_scene: PackedScene
@export var squad: PackedScene

func _ready():
	add_child(player_scene.instantiate())
	add_child(squad.instantiate())

func player() -> Player: return $player as Player
