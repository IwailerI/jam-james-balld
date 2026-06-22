extends Node2D


@export var start_at: int = 1


func _ready() -> void:
	_start.call_deferred()


func _start() -> void:
	GameManager.load_level(start_at)
