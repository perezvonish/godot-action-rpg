class_name Item
extends Resource

enum Category {
	
}

@export var id: StringName
@export var title: String
@export var description: String

@export var icon: Texture2D
@export var max_stack: int = 1
