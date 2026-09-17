class_name PlayerMenu
extends CanvasLayer

signal closed

#@onready var inventory_tab: InventoryTab = %InventoryTab


func _ready() -> void:
	%CloseButton.pressed.connect(close)
	hide()


func bind_inventory(inventory: InventoryController) -> void:
	return
#	inventory_tab.bind_inventory(inventory)


func open() -> void:
#	if inventory_tab.transfers != null:
#		inventory_tab.transfers.set_active(true)
	show()
	%CloseButton.grab_focus()


func close() -> void:
	if not visible:
		return
#	if inventory_tab.transfers != null:
#		inventory_tab.transfers.set_active(false)
	get_viewport().gui_cancel_drag()
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null:
		focused.release_focus()
	hide()
	closed.emit()
