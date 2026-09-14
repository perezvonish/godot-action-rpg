extends Node2D

const MENU_SCENE := "res://scenes/menu/menu.tscn"

@export var game_scene: PackedScene
@export var player_scene: PackedScene
@export var hud_scene: PackedScene
@export var death_screen_scene: PackedScene
@export var player_menu_scene: PackedScene

var game: Node2D
var player: Player
var hud: UiHud
var death_screen: CanvasLayer
var player_menu: PlayerMenu

func _ready() -> void:
	game = game_scene.instantiate() as Node2D
	player = player_scene.instantiate() as Player
	hud = hud_scene.instantiate() as UiHud
	death_screen = death_screen_scene.instantiate() as CanvasLayer
	player_menu = player_menu_scene.instantiate() as PlayerMenu

	add_child(game)
	game.add_child(player)
	add_child(hud)
	add_child(death_screen)
	add_child(player_menu)
	player_menu.bind_inventory(player.inventory_controller)
	player_menu.closed.connect(_on_player_menu_closed)

	var player_spawn := game.get_node("PlayerSpawn") as Marker2D
	player.global_position = player_spawn.global_position
	hud.bind_health(player.health_controller)
	death_screen.hide()
	death_screen.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	player.died.connect(_on_player_died)
	death_screen.respawn_requested.connect(_on_respawn_requested)
	death_screen.menu_requested.connect(_on_menu_requested)


func _on_player_died() -> void:
	player_menu.close()
	player.set_input_enabled(false)
	death_screen.open()
	get_tree().paused = true


func _input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	if event.is_action_pressed("toggle_player_menu"):
		if player_menu.visible:
			player_menu.close()
		else:
			player.set_input_enabled(false)
			player_menu.open()
		get_viewport().set_input_as_handled()
	elif player_menu.visible and event.is_action_pressed("ui_cancel"):
		player_menu.close()
		get_viewport().set_input_as_handled()


func _on_player_menu_closed() -> void:
	player.set_input_enabled(true)


func _on_respawn_requested() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)
