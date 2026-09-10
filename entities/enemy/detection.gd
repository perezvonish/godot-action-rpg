class_name EnemyDetection
extends Area2D

signal player_entered(player: Player)

func _ready() -> void:
	body_entered.connect(_collision_check)

func _collision_check(body: Node2D) -> void:
	if body is Player:
		player_entered.emit(body)
