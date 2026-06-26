extends Node


@export var start_music: bool = true


func _ready() -> void:
	if start_music:
		MusicManager.ensure_playing.call_deferred("main")
	else:
		MusicManager.fade_to_stop.call_deferred(2)
