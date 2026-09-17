class_name WorldItem
extends Node2D

signal changed

@export var data: ItemData
@export_range(1, 9999) var quantity: int

var item: Item:
	set(value):
		if item != null and item.quantity_changed.is_connected(_on_quantity_changed):
			item.quantity_changed.disconnect(_on_quantity_changed)
		item = value
		if item != null:
			item.quantity_changed.connect(_on_quantity_changed)
		if is_node_ready():
			_update_visual()


func _ready() -> void:
	if item == null:
		item = Item.new(data, quantity)
	_update_visual()


func _update_visual() -> void:
	$Sprite2D.texture = item.data.texture if item != null and item.data != null else null


func _on_quantity_changed(_value: int) -> void:
	changed.emit()
