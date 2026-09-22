class_name InventoryTransferController
extends RefCounted

# todo: update
func transferItem(to: InventoryController, slot_id: int, item: Item) -> Item:
	if to == null or item == null or item.data == null or item.quantity <= 0:
		return item
	if slot_id < 0 or slot_id >= to.slots.size():
		return item

	return to.add_item(item, to.slots[slot_id])

const NearbyItems = preload("res://entities/player/systems/nearby_items.gd")
const WORLD_ITEM_SCENE = preload("res://entities/item/item.tscn")

var inventory: InventoryController
var nearby: NearbyItems
var world: Node2D
var active := false
var session := 0


func bind_context(bag: InventoryController, surroundings: NearbyItems, world_parent: Node2D) -> void:
	inventory = bag
	nearby = surroundings
	world = world_parent
	set_active(false)


func set_active(value: bool) -> void:
	active = value
	session += 1


func source_item(source: Dictionary) -> Item:
	if not active or source.get("controller") != self or source.get("session") != session:
		return null
	var content: Item
	if source.get("kind") == "inventory":
		var slot := _slot(source.get("index", -1))
		content = slot.currentItem if slot != null else null
	elif source.get("kind") == "world" and nearby.contains(source.get("world_item")):
		content = source.world_item.item
	if content == null or content != source.get("content") or content.data == null or content.quantity <= 0:
		return null
	return content


func can_move(source: Dictionary, target: Dictionary) -> bool:
	var content := source_item(source)
	if content == null:
		return false
	var destination: Item
	if target.get("kind") == "inventory":
		var slot := _slot(target.get("index", -1))
		if slot == null:
			return false
		destination = slot.currentItem
	elif target.get("kind") == "world":
		if source.kind != "inventory":
			return false
		if target.has("world_item"):
			if not nearby.contains(target.world_item):
				return false
			destination = target.world_item.item
		elif not is_instance_valid(world) or not world.is_inside_tree():
			return false
	else:
		return false
	if destination == content:
		return false
	if destination == null:
		return true
	if destination.data == content.data:
		return destination.quantity < maxi(1, content.data.max_stack_quantity)
	return content.quantity <= maxi(1, content.data.max_stack_quantity) and (source.kind == "world" or destination.quantity <= maxi(1, destination.data.max_stack_quantity))


func move_item(source: Dictionary, target: Dictionary) -> bool:
	if not can_move(source, target):
		return false
	var content := source_item(source)
	var source_slot: InventorySlot
	if source.kind == "inventory":
		source_slot = _slot(source.index)
		source_slot.currentItem = null
	else:
		source.world_item.item = null

	var remainder: Item
	if target.kind == "inventory":
		remainder = transferItem(inventory, target.index, content)
	elif target.has("world_item"):
		var slot := InventorySlot.new(0)
		slot.currentItem = target.world_item.item
		remainder = slot.putOrTake(content)
		target.world_item.item = slot.currentItem
		target.world_item.changed.emit()
	else:
		var dropped := WORLD_ITEM_SCENE.instantiate() as WorldItem
		dropped.item = content
		dropped.position = world.to_local(nearby.global_position + Vector2(16, 0))
		world.add_child(dropped)

	if source_slot != null:
		source_slot.currentItem = remainder
	else:
		source.world_item.item = remainder
		source.world_item.changed.emit()
		if remainder == null:
			source.world_item.queue_free()
	inventory.changed.emit()
	return true


func _slot(index: int) -> InventorySlot:
	if inventory == null or index < 0 or index >= inventory.slots.size():
		return null
	return inventory.slots[index]
