extends Area2D


@onready var cnb := ChainAndBalls.get_instance()

@export var speed: float = 120
@export var damage: int = 10

@onready var life_timer: Timer = $LifeTimer

var direction: Vector2


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	life_timer.timeout.connect(queue_free)

	direction = (cnb.player.global_position - global_position).normalized()
	rotation = direction.angle()


func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(_area: Node2D) -> void:
	cnb.health_component.damage(damage)
	queue_free()
