class_name InventoryTab
extends MarginContainer

const InventoryController = preload("res://core/inventory/inventory_controller.gd")
const TransferController = preload("res://core/inventory/item_transfer_controller.gd")
const WorldItem = preload("res://entities/item/item.gd")
const SLOT_SCENE = preload("res://ui/player_menu/inventory/inventory_cell.tscn")

var inventory: InventoryController
var transfers: TransferController
var selected_index: int = -1
var selected_world: WorldItem
var cells: Array[Button] = []
var environment_cells: Array[Button] = []
var refresh_pending := false
var group := ButtonGroup.new()

@onready var grid: GridContainer = %Grid


func bind_inventory(value: InventoryController) -> void:
	if inventory != null:
		inventory.changed.disconnect(_refresh)
	for cell in cells:
		grid.remove_child(cell)
		cell.queue_free()
	cells.clear()
	selected_index = -1
	inventory = value
	grid.columns = mini(inventory.columns, 10)
	for index in inventory.slots.size():
		var cell := SLOT_SCENE.instantiate() as Button
		cell.button_group = group
		grid.add_child(cell)
		cell.pressed.connect(_select.bind(index))
		cell.set_drag_forwarding(_drag_inventory.bind(index), _can_drop.bind({"kind": "inventory", "index": index}), _drop.bind({"kind": "inventory", "index": index}))
		cells.append(cell)
	inventory.changed.connect(_refresh)
	_refresh()


func bind_transfers(value: TransferController) -> void:
	transfers = value
	transfers.nearby.changed.connect(_queue_environment_refresh)
	_refresh_environment()


func _refresh() -> void:
	var occupied := 0
	for index in cells.size():
		var slot := inventory.slots[index]
		_fill_cell(cells[index], slot.item_data if slot != null else null, slot.quantity if slot != null else 0)
		if slot != null:
			occupied += 1
	%Capacity.text = "%d / %d ячеек" % [occupied, inventory.slots.size()]
	%EmptyHint.visible = occupied == 0
	_show_details()


func _fill_cell(cell: Button, data: ItemData, quantity: int) -> void:
	cell.get_node("Icon").texture = data.texture if data != null else null
	cell.get_node("Count").text = str(quantity) if data != null else ""
	cell.tooltip_text = data.title if data != null else "Пустая ячейка"


func _queue_environment_refresh() -> void:
	if not refresh_pending:
		refresh_pending = true
		_refresh_environment.call_deferred()


func _refresh_environment() -> void:
	refresh_pending = false
	for cell in environment_cells:
		%EnvironmentGrid.remove_child(cell)
		cell.queue_free()
	environment_cells.clear()
	if transfers == null:
		%Environment.hide()
		return
	for item in transfers.nearby.items:
		if not transfers.nearby.contains(item):
			continue
		var cell := SLOT_SCENE.instantiate() as Button
		#cell.button_group = group
		%EnvironmentGrid.add_child(cell)
		_fill_cell(cell, item.data, item.quantity)
		cell.set_pressed_no_signal(item == selected_world)
		cell.pressed.connect(_select_world.bind(item))
		cell.set_drag_forwarding(_drag_world.bind(item, cell), _can_drop.bind({"kind": "world", "item": item}), _drop.bind({"kind": "world", "item": item}))
		environment_cells.append(cell)
	var empty_cell := SLOT_SCENE.instantiate() as Button
	%EnvironmentGrid.add_child(empty_cell)
	empty_cell.text = "+"
	empty_cell.tooltip_text = "Перетащите сюда предмет из инвентаря, чтобы положить на землю"
	empty_cell.set_drag_forwarding(Callable(), _can_drop.bind({"kind": "world"}), _drop.bind({"kind": "world"}))
	environment_cells.append(empty_cell)
	%EnvironmentCount.text = "Стопок рядом: %d" % (environment_cells.size() - 1)
	_update_environment_visibility()
	_show_details()


func _notification(what: int) -> void:
	if is_node_ready() and (what == NOTIFICATION_DRAG_BEGIN or what == NOTIFICATION_DRAG_END):
		_update_environment_visibility()


func _update_environment_visibility() -> void:
	var dragging: Variant = get_viewport().gui_get_drag_data()
	var from_bag: bool = dragging is Dictionary and dragging.get("kind") == "inventory"
	%Environment.visible = environment_cells.size() > 1 or (get_viewport().gui_is_dragging() and from_bag)


func _drag_inventory(_position: Vector2, index: int) -> Variant:
	return _preview(transfers.inventory_source(index), cells[index]) if transfers != null else null


func _drag_world(_position: Vector2, item: Variant, cell: Button) -> Variant:
	if not is_instance_valid(item):
		return null
	return _preview(transfers.world_source(item), cell)


func _preview(source: Dictionary, cell: Button) -> Variant:
	if source.is_empty():
		return null
	var data := transfers.source_data(source)
	if data == null:
		return null
	var preview := TextureRect.new()
	preview.texture = data.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(48, 48)
	cell.set_drag_preview(preview)
	return source


func _can_drop(_position: Vector2, source: Variant, target: Dictionary) -> bool:
	return source is Dictionary and transfers != null and transfers.transferable(source, target) > 0


func _drop(_position: Vector2, source: Variant, target: Dictionary) -> void:
	if source is Dictionary and transfers != null:
		transfers.transfer(source, target)
		_queue_environment_refresh()


func _select(index: int) -> void:
	selected_index = index
	selected_world = null
	_show_details()


func _select_world(item: Variant) -> void:
	if not is_instance_valid(item):
		return
	selected_index = -1
	selected_world = item
	_show_details()


func _show_details() -> void:
	var data: ItemData
	var quantity := 0
	if selected_index >= 0 and inventory.slots[selected_index] != null:
		data = inventory.slots[selected_index].item_data
		quantity = inventory.slots[selected_index].quantity
	elif is_instance_valid(selected_world) and transfers != null and transfers.nearby.contains(selected_world):
		data = selected_world.data
		quantity = selected_world.quantity
	%ItemIcon.texture = data.texture if data != null else null
	%ItemTitle.text = data.title if data != null else "Выберите предмет"
	%ItemDescription.text = data.description if data != null else "Перетаскивайте предметы между инвентарём и окружением."
	%ItemQuantity.text = "В стопке: %d / %d" % [quantity, maxi(1, data.stack_size)] if data != null else ""
