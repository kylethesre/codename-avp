extends Node2D

@onready var enemy_spawner: Node = $EnemySpawner

func _ready() -> void:
	if enemy_spawner.has_signal("wave_started"):
		var wave_callable: Callable = Callable(self, "_on_wave_started")
		if not enemy_spawner.is_connected("wave_started", wave_callable):
			enemy_spawner.connect("wave_started", wave_callable)
		var current_wave_value: Variant = enemy_spawner.get("current_wave")
		var current_wave: int = int(current_wave_value)
		_on_wave_started(current_wave)
	else:
		push_error("Game: EnemySpawner is missing wave_started signal")

func _on_wave_started(wave: int) -> void:
	print("Game: Wave started signal received ", wave)
	UpgradeManager.show_upgrade_selection(3)
