extends CanvasLayer


@onready var bg: CanvasItem = $BG

var _paused_state: bool = false


func _process(_delta: float) -> void:
	var old_paused_state := _paused_state
	_paused_state = get_tree().paused

	visible = _paused_state
	bg.visible = visible

	if _paused_state != old_paused_state:
		_update_music_volume()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&'pause_game'):
		return

	get_viewport().set_input_as_handled()
	for child: Node in %ContinueButton.get_children():
		if is_instance_of(child, AudioStreamPlayer):
			(child as AudioStreamPlayer).play()
	get_tree().paused = not get_tree().paused


func _update_music_volume() -> void:
	if _paused_state:
		MusicManager.set_music_volume(-7)
	else:
		MusicManager.set_music_volume(0)
