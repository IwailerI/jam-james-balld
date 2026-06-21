## invariant: parent must be initialized and ready or null

class_name FlailBall
extends Node2D


signal position_updated

@export var rotation_speed: float = PI
@export var starting_rotation_angle: float = 0.0
@export var radius: float
@export var parent: FlailBall
@export var damage: int = 50
@export var follow_closest_enemy: bool = false

var _rotation_angle: float = 0.0
var _is_selected: bool = false
var _has_target_to_follow: bool = false
var _target_to_follow: Vector2

@onready var _line: Line2D = $Line2D
@onready var _sprite: Sprite2D = $Sprite2D

@onready var hurt_box: Area2D = $HurtBox


func _ready() -> void:
	_rotation_angle = starting_rotation_angle


	if parent != null:
		hurt_box.body_entered.connect(_on_enemy_entered)
		hurt_box.area_entered.connect(_on_enemy_entered)

		if parent.is_node_ready():
			parent.position_updated.connect(_update_position)
		else:
			(func () -> void:
				if not parent.is_node_ready():
					await parent.ready
				parent.position_updated.connect(_update_position)
			).call_deferred()
	else:
		_sprite.hide()
		_line.hide()

	Player.get_instance().updated_closest_enemy.connect(_on_player_closest_enemy_updated)


func _physics_process(_delta: float) -> void:
	if parent == null:
		position_updated.emit()


func _process(_delta: float) -> void:
	queue_redraw()


func _set_rotation_angle() -> void:
	if  not _has_target_to_follow:
		var delta: float = get_physics_process_delta_time()
		_rotation_angle += delta * rotation_speed
		_rotation_angle = fposmod(_rotation_angle, TAU)
	else:
		print(_target_to_follow)
		_rotation_angle = parent.global_position.angle_to_point(_target_to_follow)


func _update_position() -> void:
	if not is_instance_valid(parent):
		position_updated.emit()
		return

	_set_rotation_angle()

	global_position = parent.global_position + Vector2.from_angle(_rotation_angle) * radius
	_line.points = PackedVector2Array([Vector2.ZERO, to_local(parent.global_position)])

	_sprite.look_at(parent.global_position)

	position_updated.emit()


func force_update_position() -> void:
	_update_position()


func _on_enemy_entered(enemy: Node2D) -> void:
	if not enemy or not enemy.has_method("apply_knockback") or not enemy.get("health_component"):
		return

	enemy.health_component.damage(damage)

	var vel := _get_head_direction()
	var lin_vel := rotation_speed * radius
	enemy.apply_knockback(vel * lin_vel)


func _get_head_direction() -> Vector2:
	return Vector2.from_angle(_rotation_angle + TAU / 4 * signf(rotation_speed))


func set_selected(v: bool) -> void:
	_is_selected = v
	queue_redraw()


func _draw() -> void:
	# print(_target_to_follow)
	# draw_dashed_line(Vector2.ZERO, _target_to_follow - global_position, Color.RED, 2, true)
	# print(_target_to_follow)
	draw_circle(_target_to_follow - global_position, 16, Color.RED, false)

	if not _is_selected:
		return

	draw_circle(Vector2.ZERO, 16, Color.BLUE, false)

func _on_player_closest_enemy_updated(enemy: Node2D):
	if enemy == null:
		_has_target_to_follow = false
	else:
		_has_target_to_follow = true
		_target_to_follow = enemy.global_position

	# print(_has_target_to_follow, _target_to_follow)
