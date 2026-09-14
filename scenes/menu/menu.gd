extends Control

const GAME_SCENE := "res://scenes/bootstrap/bootstrap.tscn"

@onready var menu_card: PanelContainer = %MenuCard
@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	get_tree().paused = false
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	start_button.grab_focus()
	_animate_in()


func _animate_in() -> void:
	var target_position := menu_card.position
	menu_card.position.x -= 24.0
	menu_card.modulate.a = 0.0

	var tween := create_tween().set_parallel()
	tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(menu_card, "position", target_position, 0.4)
	tween.tween_property(menu_card, "modulate:a", 1.0, 0.3)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()
