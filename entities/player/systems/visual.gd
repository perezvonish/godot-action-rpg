class_name PlayerVisual
extends "res://core/animation/controller.gd"

var facing: Vector2 = Vector2.RIGHT


func _ready() -> void:
	assert(animatedSprites != null, "PlayerVisual requires an AnimatedSprite2D")
	update_movement(Vector2.ZERO)


func update_movement(movement: Vector2) -> void:
	var is_moving := not movement.is_zero_approx()
	if is_moving:
		if absf(movement.x) >= absf(movement.y):
			facing = Vector2.RIGHT if movement.x > 0.0 else Vector2.LEFT
		else:
			facing = Vector2.DOWN if movement.y > 0.0 else Vector2.UP

	match facing:
		Vector2.LEFT:
			play_animation(&"run_left" if is_moving else &"stay_left")
		Vector2.RIGHT:
			play_animation(&"run_right" if is_moving else &"stay_right")
		Vector2.UP:
			play_animation(&"run_up" if is_moving else &"stay_back")
		Vector2.DOWN:
			play_animation(&"run_down" if is_moving else &"stay_front")