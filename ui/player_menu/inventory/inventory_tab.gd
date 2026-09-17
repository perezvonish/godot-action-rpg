class_name InventoryTab
extends MarginContainer

const SLOT_SCENE = preload("res://ui/player_menu/inventory/inventory_cell.tscn")

var inventory: InventoryController
var selected_index: int = -1
var cells: Array[Button] = []
var group := ButtonGroup.new()

@onready var grid: GridContainer = %Grid


func _ready() -> void:
	%Environment.hide()
	_refresh()


func bind_inventory(value: InventoryController) -> void:
	if inventory != null:
		inventory.changed.disconnect(_refresh)
	for cell in cells:
		grid.remove_child(cell)
		cell.queue_free()
	cells.clear()
	selected_index = -1
	inventory = value
	if inventory != null:
		grid.columns = clampi(inventory.data.columns, 1, 10) if inventory.data != null else 1
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
	_show_details()


func _show_details() -> void:
	var content := _item_at(selected_index)
	var data: ItemData = content.data if content != null else null
	%ItemIcon.texture = data.texture if data != null else null
	%ItemTitle.text = data.title if data != null else "Выберите предмет"
	%ItemDescription.text = data.description if data != null else "Выберите ячейку, чтобы посмотреть описание предмета."
	%ItemQuantity.text = "В стопке: %d / %d" % [content.quantity, maxi(1, data.max_stack_quantity)] if data != null else ""
