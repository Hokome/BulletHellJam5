extends Node2D

@export var pattern: ProjectilePattern
@export var cooldown: float

var shooting := false

func _process(delta):
	if !shooting:
		shoot()

func shoot():
	shooting = true
	await pattern.shoot(self, get_parent())
	
	var timer := time_manager.create_timer(cooldown)
	add_child(timer)
	await timer.timeout
	timer.queue_free()
	
	shooting = false
