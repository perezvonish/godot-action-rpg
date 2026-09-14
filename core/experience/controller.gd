class_name ExperienceController
extends Node

signal level_changed(level: int)
signal experience_changed(experience: int)

@export var config: ExperienceConfig

var experience: int = 0
var level: int = 1

func add_experience(value: int) -> void:
	experience += value
	print("curr experience: ", experience)
	experience_changed.emit(experience)

	_update_level()


func _update_level() -> void:
	var new_level := 1

	for level_data in config.levels:
		if experience >= level_data.requiredXp:
			new_level = level_data.level
		else:
			break

	if new_level != level:
		level = new_level
		print("Level up: ", level)
		level_changed.emit(level)
