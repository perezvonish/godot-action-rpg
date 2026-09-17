class_name InventoryTransferController
extends RefCounted

func transferItem(to: InventoryController, item: Item):
	if to == null or item == null:
		return