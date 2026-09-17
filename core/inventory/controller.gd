class_name InventoryController
extends Node

signal changed

@export var data: InventoryData

var slots: Array[InventorySlot] = []


func _ready() -> void:
	if data == null:
		return
	for index in range(data.rows * data.columns):
		slots.append(InventorySlot.new(index))


func add_item(item: Item, slot: InventorySlot) -> Item:
	if slot == null:
		return item
	var slot_id := slot.getId()
	if slot_id < 0 or slot_id >= slots.size() or slots[slot_id] != slot:
		return item
	if item != null and item.quantity <= 0:
		return item

	var previous := slot.currentItem
	var previous_quantity := previous.quantity if previous != null else 0
	var remaining := slot.putOrTake(item)

	if slot.currentItem != previous:
		changed.emit()
	elif slot.currentItem != null and slot.currentItem.quantity != previous_quantity:
		changed.emit()

	return remaining


func remove_item(slot: InventorySlot) -> Item:
	return add_item(null, slot)
