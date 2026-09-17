class_name Item
extends RefCounted

var data: ItemData
var quantity: int = 1

signal quantity_changed(value: int)

func _init(item_data: ItemData = null, amount: int = 1) -> void:
	data = item_data
	quantity = amount


func addQuantity(value: int) -> int:
	if value <= 0:
		return 0

	if data == null:
		return value

	var available := maxi(0, data.max_stack_quantity - quantity)
	var added := mini(value, available)

	if added > 0:
		quantity += added
		quantity_changed.emit(quantity)

	return value - added
	
func removeQuantity(value: int) -> int:
	if value <= 0:
		return 0

	var removed := mini(value, maxi(0, quantity))

	if removed > 0:
		quantity -= removed
		quantity_changed.emit(quantity)

	return removed