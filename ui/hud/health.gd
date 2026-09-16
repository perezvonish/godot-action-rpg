class_name HudHealth
extends Node

@onready var progressBar: ProgressBar = $ProgressBar

func update(value: int) -> void:
	progressBar.value = value
