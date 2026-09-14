class_name InventoryController
extends Node

signal changed

@export_range(1, 10) var rows: int = 3
@export_range(1, 100) var columns: int = 10

var slots: Array[InventorySlot] = []


func _ready() -> void:
	slots.resize(rows * columns)


# Returns the quantity that did not fit in the inventory.
func add_item(item_data: ItemData, quantity: int = 1) -> int:
	if item_data == null or quantity <= 0:
		return quantity
	var remaining := quantity
	var limit := maxi(1, item_data.stack_size)
	for slot in slots:
		if slot != null and slot.item_data == item_data:
			var added := mini(remaining, limit - slot.quantity)
			slot.quantity += added
			remaining -= added
			if remaining == 0:
				break
	for index in slots.size():
		if remaining == 0:
			break
		if slots[index] == null:
			var slot := InventorySlot.new()
			slot.item_data = item_data
			slot.quantity = mini(remaining, limit)
			slots[index] = slot
			remaining -= slot.quantity
	if remaining != quantity:
		changed.emit()
	return remaining


func remove_item(index: int, quantity: int = 1) -> int:
	if index < 0 or index >= slots.size() or slots[index] == null or quantity <= 0:
		return 0
	var removed := mini(quantity, slots[index].quantity)
	slots[index].quantity -= removed
	if slots[index].quantity == 0:
		slots[index] = null
	changed.emit()
	return removed
