class_name Player
extends CharacterBody2D

@onready var stats: PlayerStats = $Systems/Stats
@onready var healthController: HealthController = $Systems/Health
@onready var ui_hud: UiHud = $UI/Hud

signal died

func _ready() -> void:
	_get_ready_signals()
	_get_ready_ui()
	
func _get_ready_signals():
	healthController.died.connect(_on_death)
	
func _get_ready_ui():
	ui_hud.bind_health(healthController)
	
func heal(value: int) -> void:
	healthController.heal(value)
	
func take_damage(value: int) -> void:
	print("Damage: ", value)
	healthController.takeDamage(value)

func _on_death():
	died.emit()
