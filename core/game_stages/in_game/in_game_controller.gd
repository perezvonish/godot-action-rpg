extends Node

@onready var player: Player = $Player
@onready var game_over_screen: Control = $Hud/GameOverScreen

#func _ready() -> void:
	#_get_ready_signals()

#func _get_ready_signals():
	#player.died.connect(_on_player_died)

#func _on_player_died() -> void:
#a	game_over_screen.show()
	#get_tree().paused = true
