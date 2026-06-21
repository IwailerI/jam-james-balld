class_name Player
extends CharacterBody2D


# may be null
signal updated_closest_enemy(enemy: Node2D)


@export var speed: float = 150.0
@export var acceleration: float = 1800.0
@export var closest_enemy_calc_radius: float = 1000.0
@export_flags_2d_physics var closest_enemy_calc_mask: int = 0
@export var closest_enemy_calc_max_results: int = 128

@onready var health_component: HealthComponent = $HealthComponent


static func get_instance() -> Player:
	return (Engine.get_main_loop() as SceneTree).get_first_node_in_group(&"player")


func _ready() -> void:
	health_component.died.connect(_on_died)
	health_component.damaged.connect(_on_damaged)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity = velocity.move_toward(input_dir * speed, acceleration * delta)

	move_and_slide()

	# TODO: maybe only call on change?
	var closest_enemy: Node2D = _get_closest_enemy()
	updated_closest_enemy.emit(closest_enemy)

func _on_damaged(amount: int) -> void:
	print("player took ", amount, " damage")


func _on_died() -> void:
	print("game over")

func _get_closest_enemy() -> Node2D:
	var space_state := get_world_2d().direct_space_state

	var circle_shape := CircleShape2D.new()
	circle_shape.radius = closest_enemy_calc_radius

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle_shape
	query.transform = Transform2D(0, global_position)
	query.collision_mask = closest_enemy_calc_mask

	var results := space_state.intersect_shape(query, closest_enemy_calc_max_results)

	var closest_enemy: Node2D = null
	var closest_dist_sqr: float = INF

	for r: Dictionary in results:
		var enemy: Node2D = r["collider"]
		var dist_sqr: float = global_position.distance_squared_to(enemy.global_position)

		if dist_sqr < closest_dist_sqr:
			closest_enemy = enemy
			closest_dist_sqr = dist_sqr

	return closest_enemy
