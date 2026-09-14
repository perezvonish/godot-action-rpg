class_name UiHud
extends CanvasLayer

@onready var health_progress_bar: ProgressBar = $Health/ProgressBar

func bind_health(health: HealthController) -> void:
	health.changed.connect(update_health)
	update_health(health.current_health, health.max_health)

func update_health(value: int, maximum: int) -> void:
	health_progress_bar.max_value = maximum
	health_progress_bar.value = value
