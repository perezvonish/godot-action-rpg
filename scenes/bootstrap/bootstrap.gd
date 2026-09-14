extends Node

@export var player_scene: PackedScene
@export var hud_scene: PackedScene
@export var death_screen_scene: PackedScene

var player: Player

func _ready() -> void:
	player = player_scene.instantiate() as Player
	add_child(player)
