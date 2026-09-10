extends Node

@onready var input = $Systems/Input
@onready var movement = $Systems/Movement
@onready var stats: PlayerStats = $Systems/Stats
@onready var experience: PlayerStats = $Systems/Experience

func _ready() -> void:
	var t := stats.hello_world()
