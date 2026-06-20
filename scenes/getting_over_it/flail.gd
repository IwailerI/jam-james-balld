extends RigidBody2D


@export var anchor: RigidBody2D


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
