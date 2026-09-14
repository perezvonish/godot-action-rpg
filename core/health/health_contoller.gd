class_name HealthController
extends Node

signal changed(current: int, maximum: int)
signal died()

@export var max_health: int = 1

var current_health: int

func _ready() -> void:
	current_health = max_health


func initialize(maximum: int) -> void:
	max_health = maxi(maximum, 1)
	current_health = max_health
	changed.emit(current_health, max_health)

func heal(value: int) -> void:
	current_health = mini(current_health + value, max_health)
	changed.emit(current_health, max_health)

func take_damage(value: int) -> void:
	current_health = maxi(current_health - value, 0)
	changed.emit(current_health, max_health)
	
	if current_health <= 0:
		died.emit()
