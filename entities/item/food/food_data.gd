class_name FoodItem
extends ItemData

@export var health_restore: int

signal food_consumed(food: FoodItem)

func eat(player: Player) -> void: 
	player._take_damage()	
	food_consumed.emit()
