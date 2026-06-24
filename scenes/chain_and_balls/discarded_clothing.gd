extends RigidBody2D


func _ready() -> void:
	var n := get_tree().get_first_node_in_group(&"boss") as PhysicsBody2D
	if is_instance_valid(n):
		add_collision_exception_with(n)
