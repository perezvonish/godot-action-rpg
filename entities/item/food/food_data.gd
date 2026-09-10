class_name FoodItem
extends ItemData

@export var health_restore: int

signal food_consumed(food: FoodItem)

func eat() -> void: 
	food_consumed.emit(self)
