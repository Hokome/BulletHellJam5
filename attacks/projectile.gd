extends Area2D

@export var speed: float
@export var faction: Battle.Faction
@export var damage := 1
@export var lifetime: float = 20

func _ready():
	var timer := time_manager.create_timer(lifetime)
	add_child(timer)
	timer.timeout.connect(queue_free)

func _physics_process(delta):
	translate(transform.basis_xform(Vector2.RIGHT) * delta * speed)

func _on_area_entered(area):
	if area is Hurtbox:
		if area.faction != faction:
			area.damage(damage)
			queue_free()
