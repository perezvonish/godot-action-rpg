extends RefCounted

const Inventory = preload("res://core/inventory/inventory_controller.gd")
const Slot = preload("res://core/inventory/inventory_slot.gd")
const NearbyItems = preload("res://entities/player/systems/nearby_items.gd")
const WorldItem = preload("res://entities/item/item.gd")
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
	return source.slot.item_data if source.kind == "inventory" else source.item.data


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
	var quantity: int = source.slot.quantity if source.kind == "inventory" else source.item.quantity
	var target_data: ItemData
	var target_quantity := 0
	if target.get("kind") == "inventory":
		var index: int = target.get("index", -1)
		if index < 0 or index >= inventory.slots.size() or (source.kind == "inventory" and source.index == index):
			return 0
		var slot := inventory.slots[index]
		if slot != null:
			target_data = slot.item_data
			target_quantity = slot.quantity
	elif target.get("kind") == "world":
		if target.has("item") and not is_instance_valid(target.item):
			return 0
		var item: WorldItem = target.get("item")
		if item != null:
			if not nearby.contains(item) or (source.kind == "world" and source.item == item):
				return 0
			target_data = item.data
			target_quantity = item.quantity
		elif source.kind != "inventory" or not is_instance_valid(world) or not world.is_inside_tree():
			return 0
	else:
		return 0
	if target_data != null and target_data != data:
		return 0
	return mini(quantity, maxi(0, maxi(1, data.stack_size) - target_quantity))


# Both sides are changed synchronously before notifying their views.
func transfer(source: Dictionary, target: Dictionary) -> int:
	var moved := transferable(source, target)
	if moved <= 0:
		return 0
	var data := source_data(source)
	var target_item: WorldItem = null
	if target.kind == "inventory":
		var index: int = target.index
		if inventory.slots[index] == null:
			inventory.slots[index] = Slot.new()
			inventory.slots[index].item_data = data
		inventory.slots[index].quantity += moved
	else:
		target_item = target.get("item")
		if target_item == null:
			target_item = ITEM_SCENE.instantiate() as WorldItem
			target_item.data = data
			target_item.quantity = moved
			target_item.position = world.to_local(nearby.global_position + Vector2(32, 16))
			world.add_child(target_item)
		else:
			target_item.quantity += moved
	var source_item: WorldItem = null
	if source.kind == "inventory":
		source.slot.quantity -= moved
		if source.slot.quantity == 0:
			inventory.slots[source.index] = null
	else:
		source_item = source.item
		source_item.quantity -= moved
		if source_item.quantity == 0:
			source_item.queue_free()
	if source.kind == "inventory" or target.kind == "inventory":
		inventory.changed.emit()
	if source_item != null:
		source_item.changed.emit()
	if target_item != null:
		target_item.changed.emit()
	return moved
