class_name Player
extends CharacterBody2D

@onready var systems_stats: PlayerStats = $Systems/Stats
@onready var health: HealthController = $Systems/Health
@onready var ui_hud: UiHud = $UI/Hud

func _ready() -> void:
	ui_hud.bind_health(health)
	
func heal(value: int) -> void:
	health.heal(value)
	
func _take_damage(value: int) -> void:
	print("Damage: ", value)
	health.takeDamage(value)
