class_name PlayerMenu
extends CanvasLayer

const InventoryController = preload("res://core/inventory/inventory_controller.gd")

signal closed

@onready var inventory_tab: InventoryTab = %InventoryTab


func _ready() -> void:
	%CloseButton.pressed.connect(close)
	hide()


func bind_inventory(inventory: InventoryController) -> void:
	inventory_tab.bind_inventory(inventory)


func open() -> void:
	show()
	%CloseButton.grab_focus()


func close() -> void:
	if not visible:
		return
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null:
		focused.release_focus()
	hide()
	closed.emit()
