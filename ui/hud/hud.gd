class_name UiHud
extends CanvasLayer

@onready var healthProgressBar: ProgressBar = $Health/ProgressBar

func bind_health(health: HealthController) -> void:
	health.changed.connect(updateHealth)
	updateHealth(health.health, health.maxHealth)

func updateHealth(value: int, maxValue: int) -> void:
	healthProgressBar.max_value = maxValue
	healthProgressBar.value = value
