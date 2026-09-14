extends Node

@export var player_scene: PackedScene
@export var hud_scene: PackedScene
@export var death_screen_scene: PackedScene

var player: Player
var hud: UiHud

func _ready() -> void:
	player = player_scene.instantiate() as Player
	hud = hud_scene.instantiate() as UiHud

	add_child(player)
	add_child(hud)

	hud.bind_health(player.health_controller)
