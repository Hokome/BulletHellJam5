extends Area2D

@export var speed: float
@export var faction: Battle.Faction
@export var damage := 1

func _physics_process(delta):
	translate(transform.basis_xform(Vector2.RIGHT) * delta * speed)

func _on_area_entered(area):
	if area is Hurtbox:
		if area.faction != faction:
			area.damage(damage)
			queue_free()
