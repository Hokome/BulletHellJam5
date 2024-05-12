class_name Unit extends CharacterBody2D

@export var speed: float
@export var attack_cooldown: float
@export var projectile_scene: PackedScene

var squad: Squad
var target_position: Vector2
var is_repositioning: bool

var enemies_in_range: Array[Hurtbox] = []

var attack_timer: BattleTimer

func _ready():
	attack_timer = time_manager.create_timer(attack_cooldown)
	add_child(attack_timer)
	attack_timer.name = "attack_timer"

func _physics_process(delta):
	if is_repositioning:
		if is_at_destination(delta):
			is_repositioning = false
			global_position = target_position
			velocity = Vector2.ZERO
		else:
			var diff = (target_position - global_position)
			velocity = diff.normalized() * speed
			move_and_slide()
	elif can_attack():
		if enemies_in_range.size() > 0:
			var target = enemies_in_range[0]
			var proj: Node2D = projectile_scene.instantiate()
			battle.add_child(proj)
			proj.global_position = global_position
			proj.look_at(target.global_position)
			
			attack_timer.start()


func can_attack() -> bool: return attack_timer.time_left <= 0
func is_at_destination(delta) -> bool: return (target_position - global_position).length() <= speed * delta

func reposition(pos):
	is_repositioning = true
	if pos is Vector2:
		target_position = pos
	else:
		target_position = pos.global_position


func _on_range_area_entered(area):
	if area is Hurtbox:
		if area.faction != $hurtbox.faction:
			enemies_in_range.append(area)

func _on_range_area_exited(area):
	if area is Hurtbox:
		if area.faction != $hurtbox.faction:
			enemies_in_range.erase(area)
