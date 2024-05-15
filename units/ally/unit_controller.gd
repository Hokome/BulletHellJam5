class_name UnitController extends CharacterBody2D

@export var speed: float
@export var attack_cooldown: float
@export var projectile_scene: PackedScene

var squad: SquadController
var target_position: Vector2
var is_repositioning: bool

var enemies_in_range: Array[Hurtbox] = []

var attack_timer: BattleTimer

var unit_info: UM.Unit

func update_unit_info():
	unit_info.hp = $health.value
	
	unit_info.marked_delete = false

func import_unit(info: UM.Unit):
	unit_info = info
	
	$health.max_value = unit_info.get_max_hp()
	$health.value = unit_info.hp
	
	speed = info.get_speed()
	
	unit_info.marked_delete = true

func _ready():
	$sprite.play("idle")
	attack_timer = time_manager.create_timer(attack_cooldown)
	add_child(attack_timer)
	attack_timer.name = "attack_timer"

func _physics_process(delta):
	if is_repositioning:
		if is_at_destination(delta):
			is_repositioning = false
			global_position = target_position
			velocity = Vector2.ZERO
			$sprite.animation = "idle"
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
	$sprite.animation = "run"
	is_repositioning = true
	if pos is Vector2:
		target_position = pos
	else:
		target_position = pos.global_position
	
	var diff := target_position - global_position
	$sprite.flip_h = diff.x < 0

func _on_range_area_entered(area):
	if area is Hurtbox:
		if area.faction != $hurtbox.faction:
			enemies_in_range.append(area)

func _on_range_area_exited(area):
	if area is Hurtbox:
		if area.faction != $hurtbox.faction:
			enemies_in_range.erase(area)
