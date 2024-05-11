class_name StateMachine extends Node

@export var default_state: String

var current_state: State

func _ready():
	set_state(default_state)

func set_state(state_name: String):
	if current_state:
		current_state.on_exit()
	
	current_state = get_node_or_null(state_name)
	if current_state == null: push_error("State '" + state_name + "' not found")
	current_state.on_enter()

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)
