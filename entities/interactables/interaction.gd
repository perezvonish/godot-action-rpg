class_name InteractionComponent
extends Area2D

signal interacted(actor: Node)

var nearby_player: Player


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		nearby_player = body
		print("Игрок вошёл в зону взаимодействия")


func _on_body_exited(body: Node2D) -> void:
	if body == nearby_player:
		nearby_player = null
		print("Игрок вышел из зоны взаимодействия")


func interact(actor: Node) -> void:
	if not is_instance_valid(nearby_player):
		return

	if actor != nearby_player:
		return

	interacted.emit(actor)