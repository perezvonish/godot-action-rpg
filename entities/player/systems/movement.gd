extends Node

@export var speed := 300.0

func _physics_process(delta: float) -> void:	
	var player: CharacterBody2D = get_parent().get_parent()
	
	var direction := Input.get_vector(
		"player_move_left",
		"player_move_right",
		"player_move_up",
		"player_move_down"
	)
	
	#print("direction:", direction)
	#print("position:", player.global_position)
	
	player.velocity = direction * speed
	#print(player.velocity)
	
	player.move_and_slide()
