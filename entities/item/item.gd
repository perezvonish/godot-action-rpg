class_name Item
extends Node2D

@export var data: ItemData
@export_range(1, 9999) var quantity: int = 1

signal changed

@onready var sprite2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite2d.texture = data.texture if data != null else null
