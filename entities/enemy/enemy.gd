class_name Enemy
extends Node

@export var data: EnemyData

@onready var detection_area: EnemyDetection = $"Detection Area (Area2D)";
@onready var sprite: Sprite2D = $"Texture (sprite2d)";



func _ready() -> void:
	detection_area.player_entered.connect(_make_hit)
	sprite.texture = data.texture

func _make_hit(player: Player) -> void:
	player._take_damage(data.damage)
