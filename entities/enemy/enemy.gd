@tool
class_name Enemy
extends CharacterBody2D

@export var data: EnemyData:
	set(value):
		data = value
		if Engine.is_editor_hint() and is_node_ready():
			_update_visual()

@onready var detection_area: EnemyDetection = $"Detection Area (Area2D)";
@onready var sprite: Sprite2D = $"Texture (sprite2d)";
@onready var health_controller: HealthController = $Systems/Health

func _ready() -> void:
	_update_visual()
	if Engine.is_editor_hint():
		return

	detection_area.player_entered.connect(_make_hit)
	health_controller.initialize(data.max_health)


func take_damage(value: int) -> void:
	health_controller.take_damage(value)

func _make_hit(player: Player) -> void:
	player.take_damage(data.base_damage)

func _update_visual() -> void:
	sprite.texture = data.texture if data != null else null
