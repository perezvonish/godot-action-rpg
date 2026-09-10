class_name Item
extends Node2D

@export var data: ItemData

@onready var sprite2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite2d.texture = data.texture
