class_name Unit extends CharacterBody2D

signal anchor_changed

@export var speed: float

var squad: Squad
var anchor: Node2D

func _ready():
	anchor_changed.connect(func(): $state_machine.set_state("repositioning"))

func _physics_process(_delta):
	move_and_slide()
