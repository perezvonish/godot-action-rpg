extends Node

@export_group("Menus")
@export var main_menu_scene: PackedScene

@export_group("Game")
@export var game_scene: PackedScene
@export var player_scene: PackedScene

@export_group("UI")
@export var hud_scene: PackedScene
@export var death_screen_scene: PackedScene
@export var player_menu_scene: PackedScene

var main_menu: Control
var game: Node2D
var player: Player
var player_menu: PlayerMenu
var hud: UiHud
var death_screen: CanvasLayer

func _ready() -> void:
	_handle_main_menu()


func _handle_main_menu():
	main_menu = main_menu_scene.instantiate() as Control
	main_menu.game_start_requested.connect(_on_game_start_requested)
	add_child(main_menu)

func _on_game_start_requested():
	remove_child(main_menu)
	main_menu.queue_free()
	main_menu = null

	game = game_scene.instantiate()
	player = player_scene.instantiate()
	hud = hud_scene.instantiate()
	player_menu = player_menu_scene.instantiate()
	death_screen = death_screen_scene.instantiate()
	death_screen.hide()

	add_child(game)
	var objects := game.get_node("Objects")
	var player_spawn := objects.get_node("PlayerSpawner") as Marker2D
	player.position = player_spawn.position
	objects.add_child(player)
	add_child(player_menu)
	player_menu.bind_inventory(player.inventory_controller)
	player_menu.closed.connect(_on_player_menu_closed)
	add_child(hud)
	hud.bind_health(player.health_controller)
	add_child(death_screen)

#
#	death_screen.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
#	player.died.connect(_on_player_died)
#	death_screen.respawn_requested.connect(_on_respawn_requested)
#	death_screen.menu_requested.connect(_on_menu_requested)

#
#func _on_player_died() -> void:
#	player_menu.close()
#	player.set_input_enabled(false)
#	death_screen.open()
#	get_tree().paused = true
#
#
func _input(event: InputEvent) -> void:
	if get_tree().paused or player_menu == null:
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
#
#
func _on_player_menu_closed() -> void:
	player.set_input_enabled(true)
#
#
#func _on_respawn_requested() -> void:
#	get_tree().paused = false
#	get_tree().reload_current_scene()
#
#
#func _on_menu_requested() -> void:
#	get_tree().paused = false
##	get_tree().change_scene_to_file(MENU_SCENE)
