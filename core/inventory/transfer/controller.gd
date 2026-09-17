class_name InventoryTransferController
extends RefCounted

func transferItem(to: InventoryController, slot_id: int, item: Item) -> Item:
	if to == null or item == null or item.data == null or item.quantity <= 0:
		return item
	if slot_id < 0 or slot_id >= to.slots.size():
		return item

	return to.add_item(item, to.slots[slot_id])
