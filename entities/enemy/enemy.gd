class_name Enemy
extends CharacterBody2D

@export var data: EnemyData

@onready var detection_area: EnemyDetection = $"Detection Area (Area2D)";
@onready var sprite: Sprite2D = $"Texture (sprite2d)";
@onready var health_controller: HealthController = $Systems/Health

func _ready() -> void:
	detection_area.player_entered.connect(_make_hit)
	sprite.texture = data.texture
	health_controller.initialize(data.health)


func take_damage(value: int) -> void:
	health_controller.take_damage(value)

func _make_hit(player: Player) -> void:
	player.take_damage(data.damage)
