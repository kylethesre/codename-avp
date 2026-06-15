extends Node2D

@onready var enemy_spawner: Node = $EnemySpawner
var player: Node2D = null

var wave_text: Node

func _ready() -> void:
	UpgradeManager.reset()
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
		
	wave_text = get_tree().current_scene.find_child("Wave_text_counter", true)
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
	wave_text.text = "wave %d" % wave
	UpgradeManager.show_upgrade_selection(3, wave)

func _exit_tree() -> void:
	UpgradeManager.reset()

func _process(delta: float) -> void:
	if not player: return
	
	# Wrap limits set to match the background repeat size (640 width -> 320 half-width)
	var wrap_dist_x = 320.0
	var wrap_dist_y = 320.0
	
	var entities = get_tree().get_nodes_in_group("enemies") + get_tree().get_nodes_in_group("projectiles")
	
	for entity in entities:
		if not is_instance_valid(entity): continue
		
		var diff = entity.global_position - player.global_position
		
		if diff.x > wrap_dist_x:
			entity.global_position.x -= wrap_dist_x * 2
		elif diff.x < -wrap_dist_x:
			entity.global_position.x += wrap_dist_x * 2
	
