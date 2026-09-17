class_name InventorySlot
extends RefCounted

var id: int
var currentItem: Item


func _init(slot_id: int) -> void:
	id = slot_id

func getId() -> int:
	return id
	
func putOrTake(item: Item) -> Item:
	if currentItem != null and currentItem == item:
		return item

	# Объединить одинаковые предметы
	if currentItem != null and item != null and currentItem.data != null and currentItem.data == item.data:
		var remaining := currentItem.addQuantity(item.quantity)
		var added := item.quantity - remaining
		item.removeQuantity(added)

		return item if item.quantity > 0 else null 

	if item != null and item.data != null:
		var stack_limit := maxi(1, item.data.max_stack_quantity)
		if item.quantity > stack_limit:
			if currentItem != null:
				return item
			currentItem = Item.new(item.data, stack_limit)
			item.removeQuantity(stack_limit)
			return item

	var previous := currentItem
	currentItem = item
	return previous
