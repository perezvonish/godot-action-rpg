extends Control

signal game_start_requested

@onready var menu_card: PanelContainer = %MenuCard
@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	get_tree().paused = false
	_bind_buttons()

func _bind_buttons():
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	game_start_requested.emit()


func _on_quit_pressed() -> void:
	get_tree().quit()
