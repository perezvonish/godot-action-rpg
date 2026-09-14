class_name Player
extends CharacterBody2D

@onready var stats: PlayerStats = $Systems/Stats
@onready var health_controller: HealthController = $Systems/Health
@onready var experience_controller: ExperienceController = $Systems/Experience
@onready var debug_input: Node = $Systems/DebugInput

signal died

func _ready() -> void:
	_get_ready_signals()
	
func _get_ready_signals():
	health_controller.died.connect(_on_death)
	debug_input.experience_requested.connect(experience_controller.add_experience)
	
func heal(value: int) -> void:
	health_controller.heal(value)
	
func take_damage(value: int) -> void:
	print("Damage: ", value)
	health_controller.take_damage(value)

func _on_death():
	died.emit()
