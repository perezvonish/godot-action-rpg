extends Area2D

const WorldItem = preload("res://entities/item/item.gd")

signal changed

var items: Array[WorldItem] = []


func contains(item: Variant) -> bool:
	if not is_instance_valid(item) or not item is WorldItem or item.is_queued_for_deletion() or item.quantity <= 0:
		return false
#	var radius: float = $Shape.shape.radius * global_scale.x
	return item.data != null and item.is_inside_tree() # and global_position.distance_to(item.global_position) <= radius


func _physics_process(_delta: float) -> void:
	var found: Array[WorldItem] = []
	for area in get_overlapping_areas():
		var item := area.get_parent() as WorldItem
		if contains(item):
			found.append(item)
	found.sort_custom(func(a: WorldItem, b: WorldItem) -> bool: return a.get_instance_id() < b.get_instance_id())
	if found == items:
		return
	for item in items:
		if is_instance_valid(item) and item.changed.is_connected(_on_item_changed):
			item.changed.disconnect(_on_item_changed)
	items = found
	for item in items:
		item.changed.connect(_on_item_changed)
	changed.emit()


func _on_item_changed() -> void:
	changed.emit()
