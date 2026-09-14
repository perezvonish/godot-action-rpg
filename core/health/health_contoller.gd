class_name HealthController
extends Node

signal changed(current: int, max: int)
signal died()

@export var maxHealth: int

@onready var health: int

func _ready() -> void:
	health = maxHealth

func heal(value: int) -> void:
	health = mini(health + value, maxHealth)
	changed.emit(health, maxHealth)

func takeDamage(value: int) -> void:
	health = max(health - value, 0)
	changed.emit(health, maxHealth)
	
	if health <= 0:
		died.emit()
