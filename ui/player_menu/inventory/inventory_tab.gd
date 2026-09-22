class_name InventoryTab
extends MarginContainer

const SLOT_SCENE = preload("res://ui/player_menu/inventory/inventory_cell.tscn")

var inventory: InventoryController
var selected_index: int = -1
var cells: Array[Button] = []
var group := ButtonGroup.new()
var transfers: InventoryTransferController
var selected_world: Variant
var environment_cells: Array[Button] = []
var refresh_pending := false

@onready var grid: GridContainer = %Grid


func _ready() -> void:
	%Environment.hide()
	_refresh()


func bind_inventory(value: InventoryController) -> void:
	if inventory != null:
		inventory.changed.disconnect(_queue_refresh)
	for cell in cells:
		grid.remove_child(cell)
		cell.queue_free()
	cells.clear()
	selected_index = -1
	selected_world = null
	inventory = value
	if inventory != null:
		grid.columns = clampi(inventory.data.columns, 1, 10) if inventory.data != null else 1
		for index in inventory.slots.size():
			var cell := SLOT_SCENE.instantiate() as Button
			cell.button_group = group
			grid.add_child(cell)
			cell.pressed.connect(_select.bind(index))
			cell.set_drag_forwarding(_drag.bind({"kind": "inventory", "index": index}, cell), _can_drop.bind({"kind": "inventory", "index": index}), _drop.bind({"kind": "inventory", "index": index}))
			cells.append(cell)
		inventory.changed.connect(_queue_refresh)
	_refresh()


func _refresh() -> void:
	var occupied := 0
	for index in cells.size():
		var content := _item_at(index)
		var data: ItemData = content.data if content != null else null
		cells[index].get_node("Icon").texture = data.texture if data != null else null
		cells[index].get_node("Count").text = str(content.quantity) if data != null else ""
		cells[index].tooltip_text = data.title if data != null else "Пустая ячейка"
		if content != null:
			occupied += 1
	%Capacity.text = "%d / %d ячеек" % [occupied, cells.size()]
	%EmptyHint.visible = occupied == 0
	_show_details()


func _item_at(index: int) -> Item:
	if inventory == null or index < 0 or index >= inventory.slots.size():
		return null
	var slot := inventory.slots[index]
	return slot.currentItem if slot != null else null


func _select(index: int) -> void:
	selected_index = index
	selected_world = null
	_show_details()


func _show_details() -> void:
	var content := _item_at(selected_index)
	if transfers != null and transfers.nearby.contains(selected_world):
		content = selected_world.item
	var data: ItemData = content.data if content != null else null
	%ItemIcon.texture = data.texture if data != null else null
	%ItemTitle.text = data.title if data != null else "Выберите предмет"
	%ItemDescription.text = data.description if data != null else "Выберите ячейку, чтобы посмотреть описание предмета."
	%ItemQuantity.text = "В стопке: %d / %d" % [content.quantity, maxi(1, data.max_stack_quantity)] if data != null else ""


func bind_transfers(value: InventoryTransferController) -> void:
	if transfers != null:
		transfers.nearby.changed.disconnect(_queue_refresh)
	transfers = value
	if transfers != null:
		transfers.nearby.changed.connect(_queue_refresh)
	_refresh_environment()


func _queue_refresh() -> void:
	if not refresh_pending:
		refresh_pending = true
		_refresh_all.call_deferred()


func _refresh_all() -> void:
	refresh_pending = false
	_refresh()
	_refresh_environment()


func _refresh_environment() -> void:
	for cell in environment_cells:
		cell.get_parent().remove_child(cell)
		cell.queue_free()
	environment_cells.clear()
	%Environment.visible = transfers != null
	if transfers == null:
		return
	for world_item in transfers.nearby.items:
		if not transfers.nearby.contains(world_item):
			continue
		var cell := SLOT_SCENE.instantiate() as Button
		%EnvironmentGrid.add_child(cell)
		cell.button_group = group
		cell.get_node("Icon").texture = world_item.item.data.texture
		cell.get_node("Count").text = str(world_item.item.quantity)
		cell.tooltip_text = world_item.item.data.title
		cell.set_pressed_no_signal(world_item == selected_world)
		cell.pressed.connect(_select_world.bind(world_item))
		var location := {"kind": "world", "world_item": world_item}
		cell.set_drag_forwarding(_drag.bind(location, cell), _can_drop.bind(location), _drop.bind(location))
		environment_cells.append(cell)
	%EnvironmentCount.text = "Стопок рядом: %d" % environment_cells.size()
	var empty := SLOT_SCENE.instantiate() as Button
	%EnvironmentGrid.add_child(empty)
	empty.text = "+"
	empty.tooltip_text = "Перетащите сюда предмет из инвентаря, чтобы положить на землю"
	empty.set_drag_forwarding(Callable(), _can_drop.bind({"kind": "world"}), _drop.bind({"kind": "world"}))
	environment_cells.append(empty)
	_show_details()


func _select_world(world_item: Variant) -> void:
	if transfers == null or not transfers.nearby.contains(world_item):
		return
	selected_index = -1
	selected_world = world_item
	_show_details()


func _drag(_position: Vector2, location: Dictionary, cell: Button) -> Variant:
	if transfers == null or not transfers.active:
		return null
	var content: Item
	if location.kind == "inventory":
		content = _item_at(location.index)
	elif transfers.nearby.contains(location.world_item):
		content = location.world_item.item
	if content == null or content.data == null or content.quantity <= 0:
		return null
	var source := location.duplicate()
	source.controller = transfers
	source.session = transfers.session
	source.content = content
	var preview := TextureRect.new()
	preview.texture = content.data.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(48, 48)
	cell.set_drag_preview(preview)
	return source


func _can_drop(_position: Vector2, source: Variant, target: Dictionary) -> bool:
	return source is Dictionary and transfers != null and transfers.can_move(source, target)


func _drop(_position: Vector2, source: Variant, target: Dictionary) -> void:
	if source is Dictionary and transfers != null:
		transfers.move_item(source, target)
		_queue_refresh()
