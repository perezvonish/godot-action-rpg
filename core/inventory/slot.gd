class_name InventorySlot
extends RefCounted

var id: int
var currentItem: Item


func _init(slot_id: int) -> void:
	id = slot_id

func getId() -> int:
	return id
	
func putOrTake(item: Item) -> Item:
	# Объединить одинаковые предметы
	if currentItem.data != null and currentItem.data == item.data:
		var remaining := currentItem.addQuantity(item.quantity)
		var added := item.quantity - remaining
		item.removeQuantity(added)

		return item if item.quantity > 0 else null 

	var previous := currentItem
	currentItem = item
	return previous