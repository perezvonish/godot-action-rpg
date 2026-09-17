extends RefCounted

const Inventory = preload("res://core/inventory/inventory_controller.gd")
const Slot = preload("res://core/inventory/slot.gd")
const NearbyItems = preload("res://entities/player/systems/nearby_items.gd")
const WorldItem = preload("res://entities/item/world_item.gd")
const ITEM_SCENE = preload("res://entities/item/item.tscn")

var inventory: Inventory
var nearby: NearbyItems
var world: Node2D
var active: bool = false
var session: int = 0


func _init(bag: Inventory, surroundings: NearbyItems, game: Node2D) -> void:
	inventory = bag
	nearby = surroundings
	world = game


func set_active(value: bool) -> void:
	active = value
	session += 1


func inventory_source(index: int) -> Dictionary:
	if not active or index < 0 or index >= inventory.slots.size() or inventory.slots[index] == null:
		return {}
	return {"controller": self, "session": session, "kind": "inventory", "index": index, "slot": inventory.slots[index]}


func world_source(item: WorldItem) -> Dictionary:
	if not active or not nearby.contains(item):
		return {}
	return {"controller": self, "session": session, "kind": "world", "item": item}


func source_data(source: Dictionary) -> ItemData:
	if not _valid_source(source):
		return null
	return source.slot.currentItem.data if source.kind == "inventory" else source.item.item.data


func _valid_source(source: Dictionary) -> bool:
	if not active or source.get("controller") != self or source.get("session") != session:
		return false
	if source.get("kind") == "inventory":
		var index: int = source.index
		return index >= 0 and index < inventory.slots.size() and inventory.slots[index] != null and inventory.slots[index] == source.slot
	return source.get("kind") == "world" and nearby.contains(source.get("item"))


func transferable(source: Dictionary, target: Dictionary) -> int:
	var data := source_data(source)
	if data == null:
		return 0
	var quantity: int = source.slot.currentItem.quantity if source.kind == "inventory" else source.item.item.quantity
	var target_data: ItemData
	var target_quantity := 0
	if target.get("kind") == "inventory":
		var index: int = target.get("index", -1)
		if index < 0 or index >= inventory.slots.size() or (source.kind == "inventory" and source.index == index):
			return 0
		var slot := inventory.slots[index]
		if slot != null:
			target_data = slot.currentItem.data
			target_quantity = slot.currentItem.quantity
	elif target.get("kind") == "world":
		if target.has("item") and not is_instance_valid(target.item):
			return 0
		var item: WorldItem = target.get("item")
		if item != null:
			if not nearby.contains(item) or (source.kind == "world" and source.item == item):
				return 0
			target_data = item.item.data
			target_quantity = item.item.quantity
		elif source.kind != "inventory" or not is_instance_valid(world) or not world.is_inside_tree():
			return 0
	else:
		return 0
	if target_data != null and target_data != data:
		return 0
	return mini(quantity, maxi(0, maxi(1, data.max_stack_quantity) - target_quantity))


# Both sides are changed synchronously before notifying their views.
func transfer(source: Dictionary, target: Dictionary) -> int:
	var moved := transferable(source, target)
	if moved <= 0:
		return 0
	var source_content: Item = source.slot.currentItem if source.kind == "inventory" else source.item.item
	var target_content: Item
	var target_item: WorldItem = null
	if target.kind == "inventory":
		var slot := inventory.slots[int(target.index)]
		target_content = slot.currentItem if slot != null else null
	else:
		target_item = target.get("item")
		target_content = target_item.item if target_item != null else null

	var moving_whole_item := target_content == null and moved == source_content.quantity
	if moving_whole_item:
		target_content = source_content
	else:
		if target_content == null:
			target_content = Item.new(source_content.data, 0)
		target_content.quantity += moved
		source_content.quantity -= moved

	var source_item: WorldItem = null
	if source.kind == "inventory":
		if moving_whole_item or source_content.quantity == 0:
			source.slot.currentItem = null
			inventory.slots[source.index] = null
	else:
		source_item = source.item
		if moving_whole_item or source_content.quantity == 0:
			source_item.item = null
			source_item.queue_free()

	if target.kind == "inventory":
		var index: int = target.index
		if inventory.slots[index] == null:
			inventory.slots[index] = Slot.new(index)
		inventory.slots[index].currentItem = target_content
	else:
		if target_item == null:
			target_item = ITEM_SCENE.instantiate() as WorldItem
			target_item.item = target_content
			target_item.position = world.to_local(nearby.global_position + Vector2(32, 16))
			world.add_child(target_item)

	if source.kind == "inventory" or target.kind == "inventory":
		inventory.changed.emit()
	if source_item != null and source_item.item == null:
		source_item.changed.emit()
	if not moving_whole_item:
		source_content.quantity_changed.emit(source_content.quantity)
		target_content.quantity_changed.emit(target_content.quantity)
	return moved
