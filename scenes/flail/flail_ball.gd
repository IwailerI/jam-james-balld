class_name FlailBall
extends Node2D


signal position_updated


@export var rotation_speed: float = PI
@export var starting_rotation_angle: float = 0.0
@export var radius: float:
	set(v):
		radius = v
		_update_position()
@export var parent: FlailBall:
	set(v):
		if is_instance_valid(parent):
			parent.position_updated.disconnect(_update_position)
		parent = v
		_update_position()
		_update_signal()


var _rotation_angle: float = 0.0


func _ready() -> void:
	_update_signal.call_deferred()


func _update_position() -> void:
	if not is_instance_valid(parent):
		position_updated.emit()
		return

	var delta: float = get_physics_process_delta_time()
	_rotation_angle += delta * rotation_speed
	_rotation_angle = fposmod(_rotation_angle, TAU)

	global_position = parent.global_position + Vector2.from_angle(_rotation_angle) * radius

	position_updated.emit()


func _update_signal() -> void:
	if is_instance_valid(parent) and not parent.position_updated.is_connected(_update_position):
		parent.position_updated.connect(_update_position)


func force_update_position() -> void:
	_update_position()
