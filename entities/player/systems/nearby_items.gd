extends Area2D

signal changed

var items: Array[WorldItem] = []


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area2D) -> void:
	print("entered")
	var world_item := area.get_parent() as WorldItem

	if world_item == null or items.has(world_item):
		return

	items.append(world_item)
	world_item.changed.connect(_on_item_changed)

	changed.emit()


func _on_area_exited(area: Area2D) -> void:
	print("exited")
	var world_item := area.get_parent() as WorldItem

	if world_item == null or not items.has(world_item):
		return

	items.erase(world_item)

	if world_item.changed.is_connected(_on_item_changed):
		world_item.changed.disconnect(_on_item_changed)

	changed.emit()


func _on_item_changed() -> void:
	changed.emit()


func contains(world_item: Variant) -> bool:
	if not is_instance_valid(world_item):
		return false
	if not world_item is WorldItem:
		return false
	if world_item.is_queued_for_deletion():
		return false
	if world_item.item == null:
		return false

	return (
		items.has(world_item)
		and world_item.is_inside_tree()
		and world_item.item.data != null
		and world_item.item.quantity > 0
	)