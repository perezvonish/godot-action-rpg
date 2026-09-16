class_name Player
extends CharacterBody2D

const InventoryController = preload("res://core/inventory/inventory_controller.gd")

@onready var stats: PlayerStats = $Systems/Stats
@onready var health_controller: HealthController = $Systems/Health
@onready var experience_controller: ExperienceController = $Systems/Experience
@onready var debug_input: Node = $Systems/DebugInput
@onready var inventory_controller: InventoryController = $Systems/Inventory
@onready var visual: PlayerVisual = $Visual
@onready var movement = $Systems/Movement

var input_enabled: bool = true

signal died


func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	debug_input.set_process_unhandled_input(enabled)
	if not enabled:
		velocity = Vector2.ZERO
		visual.update_movement(Vector2.ZERO)

func _ready() -> void:
	_get_ready_signals()
	
func _get_ready_signals():
	movement.movement_updated.connect(visual.update_movement)
	health_controller.died.connect(_on_death)
	debug_input.experience_requested.connect(experience_controller.add_experience)
	
func heal(value: int) -> void:
	health_controller.heal(value)
	
func take_damage(value: int) -> void:
	print("Damage: ", value)
	health_controller.take_damage(value)

func _on_death():
	died.emit()
