extends Area2D

@export var speed: float

func _physics_process(delta):
	translate(transform.basis_xform(Vector2.RIGHT) * delta * speed)
