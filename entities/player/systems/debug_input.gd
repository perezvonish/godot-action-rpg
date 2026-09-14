extends Node

signal experience_requested(value: int)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dev"):
		experience_requested.emit(10)
