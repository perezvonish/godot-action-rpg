class_name BaseInteractable
extends StaticBody2D

@onready var interaction: InteractionComponent = $Components/Interaction

func _ready() -> void:
	interaction.interacted.connect(_on_interacted)
	
	
func _on_interacted(actor: Node) -> void:
	print(self.actor, "Method not implimented: _on_interacted")
	pass