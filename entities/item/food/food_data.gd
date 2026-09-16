class_name FoodItem
extends ItemData

@export_range(0, 100) var health_restore: int

signal food_consumed(food: FoodItem)

func eat() -> void: 
	food_consumed.emit(self)
