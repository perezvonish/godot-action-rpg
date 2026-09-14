extends Node

@export var speed := 300.0

@onready var player: Player = owner as Player

func _ready() -> void:
	assert(player != null, "Movement must be owned by a CharacterBody2D")


func _physics_process(_delta: float) -> void:
	if not player.input_enabled:
		player.velocity = Vector2.ZERO
		return
	var direction := Input.get_vector(
		"player_move_left",
		"player_move_right",
		"player_move_up",
		"player_move_down"
	)

	player.velocity = direction * speed
	player.move_and_slide()
