extends CanvasLayer

signal respawn_requested
signal menu_requested

@onready var overlay: Control = %Overlay
@onready var card: PanelContainer = %DeathCard
@onready var respawn_button: Button = %RespawnButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	respawn_button.pressed.connect(respawn_requested.emit)
	menu_button.pressed.connect(menu_requested.emit)


func open() -> void:
	show()
	overlay.modulate.a = 0.0
	card.pivot_offset = card.size * 0.5
	card.scale = Vector2(0.96, 0.96)

	var tween := create_tween().set_parallel()
	tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.25)
	tween.tween_property(card, "scale", Vector2.ONE, 0.35)
	respawn_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		menu_requested.emit()
