class_name InventoryTab
extends MarginContainer

const InventoryController = preload("res://core/inventory/inventory_controller.gd")

const SLOT_SCENE := preload("res://ui/player_menu/inventory/inventory_cell.tscn")

var inventory: InventoryController
var selected_index: int = -1
var cells: Array[Button] = []

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
	grid.columns = inventory.columns
	var group := ButtonGroup.new()
	for index in inventory.slots.size():
		var cell := SLOT_SCENE.instantiate() as Button
		cell.button_group = group
		grid.add_child(cell)
		cell.pressed.connect(_select.bind(index))
		cells.append(cell)
	inventory.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var occupied := 0
	for index in cells.size():
		var slot := inventory.slots[index]
		var cell := cells[index]
		var icon: TextureRect = cell.get_node("Icon")
		var count: Label = cell.get_node("Count")
		icon.texture = slot.item_data.texture if slot != null else null
		count.text = str(slot.quantity) if slot != null else ""
		cell.tooltip_text = slot.item_data.title if slot != null else "Пустая ячейка"
		if slot != null:
			occupied += 1
	%Capacity.text = "%d / %d ячеек" % [occupied, inventory.slots.size()]
	%EmptyHint.visible = occupied == 0
	_show_details()


func _select(index: int) -> void:
	selected_index = index
	_show_details()


func _show_details() -> void:
	var slot: InventorySlot = null
	if selected_index >= 0:
		slot = inventory.slots[selected_index]
	%ItemIcon.texture = slot.item_data.texture if slot != null else null
	%ItemTitle.text = slot.item_data.title if slot != null else "Выберите предмет"
	%ItemDescription.text = slot.item_data.description if slot != null else "Здесь появится его описание."
	%ItemQuantity.text = "В стопке: %d / %d" % [slot.quantity, maxi(1, slot.item_data.stack_size)] if slot != null else ""
