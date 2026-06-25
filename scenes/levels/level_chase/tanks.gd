extends PathFollow2D

@export var speed: float = 75

var _started: bool = false
@onready var cnb: ChainAndBalls = ChainAndBalls.get_instance()



func _ready() -> void:
	($Death as Area2D).body_entered.connect(_kill_object)
	($Death as Area2D).area_entered.connect(_kill_object)


func _physics_process(delta: float) -> void:
	if not _started:
		return

	for child: Node in get_children():
		if child.is_in_group(&"upright"):
			var s := child as Sprite2D
			s.global_rotation = 0
			s.flip_h = Vector2.RIGHT.rotated(rotation).x < 0

	progress += delta * speed


func _kill_object(node: Node) -> void:
	if node == cnb.flail:
		cnb.flail.apply_impulse(Vector2.ONE.rotated(rotation) * 300.0)
		return

	if node == cnb.player:
		cnb.health_component.damage(9999999999)
		return

	var hc := node.get("health_component") as HealthComponent
	if is_instance_valid(hc):
		hc.damage(999999999)


func start() -> void:
	_started = true
