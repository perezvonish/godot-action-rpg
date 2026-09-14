extends Node2D

const MENU_SCENE := "res://scenes/menu/menu.tscn"

@export var game_scene: PackedScene
@export var player_scene: PackedScene
@export var hud_scene: PackedScene
@export var death_screen_scene: PackedScene

var game: Node2D
var player: Player
var hud: UiHud
var death_screen: CanvasLayer

func _ready() -> void:
	game = game_scene.instantiate() as Node2D
	player = player_scene.instantiate() as Player
	hud = hud_scene.instantiate() as UiHud
	death_screen = death_screen_scene.instantiate() as CanvasLayer

	add_child(game)
	game.add_child(player)
	add_child(hud)
	add_child(death_screen)

	var player_spawn := game.get_node("PlayerSpawn") as Marker2D
	player.global_position = player_spawn.global_position
	hud.bind_health(player.health_controller)
	death_screen.hide()
	death_screen.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	player.died.connect(_on_player_died)
	death_screen.respawn_requested.connect(_on_respawn_requested)
	death_screen.menu_requested.connect(_on_menu_requested)


func _on_player_died() -> void:
	death_screen.open()
	get_tree().paused = true


func _on_respawn_requested() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)
