extends Node2D

signal wave_started(wave: int)

@export_category("Spawn Settings")
## Seconds between each wave. Upgrade selection appears when the timer fires.
@export var wave_duration: float = 15.0
## Drag and drop your EnemyPool.tscn file here once
@export var enemy_pool_scene: PackedScene
@export var current_wave: int = 1
@export var spawn_radius: float = 400.0
@export var spawn_cooldown: float = .1
@export var spawn_rate_curve: Curve

@onready var timer: Timer = $Timer
@onready var wave_timer: Timer = $WaveTimer
var player: Node2D = null
var pool_instance: Node = null

func _ready() -> void:
	# Find the player
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
	
	# Instantiate the pool scene in memory so we can read its children
	if enemy_pool_scene:
		pool_instance = enemy_pool_scene.instantiate()
	else:
		push_error("Hey! You forgot to assign the EnemyPool scene to the Spawner.")
	
	# Setup and start the spawn timer
	timer.wait_time = spawn_cooldown
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
	# Wave timer triggers upgrade selection at the start of each wave
	wave_timer.wait_time = wave_duration
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	wave_timer.start()

func _on_timer_timeout() -> void:
	# Safety check: make sure the pool has enemies and player exists
	if not pool_instance or pool_instance.get_child_count() == 0 or not player:
		return
		
	spawn_random_enemy()

func spawn_random_enemy() -> void:
	# 1. Get all the enemy templates inside the pool scene
	var available_enemies = pool_instance.get_children()
	
	 # Compute the spawning graph and output a multiplyer based on it.
	var curve_strength: float = 100 * spawn_rate_curve.sample_baked(get_tree().get_nodes_in_group('enemies').size())
	
	# Loop through available_enemies and try to spawn each one based on its waves value(spawn chance)
	for Enemy in available_enemies:
		
		var spawn_chance: float = 0.0
		var max_defined_waves = Enemy.stats.waves.size()
		
		if max_defined_waves == 0:
			continue
			
		if current_wave <= max_defined_waves:
			spawn_chance = float(Enemy.stats.waves[current_wave-1])
		else:
			var base_chance = float(Enemy.stats.waves[max_defined_waves-1])
			var waves_past = current_wave - max_defined_waves
			spawn_chance = base_chance * pow(1.2, float(waves_past))
			
		var random_dice_roll: float = randf_range(1.0, 100.0)
		# 2. Check if current selected enemy can be spawned.
		# 2.5 Also slow spawning if there are too many enemies on the board.
		if random_dice_roll <= spawn_chance and random_dice_roll <= curve_strength:
			
			# 3. Duplicate it so we don't steal the original template
			var enemy_instance = Enemy.duplicate() as Node2D
			
			# 4. Calculate a random position on a circle around the player
			var random_angle = randf_range(0, 2 * PI)
			var spawn_offset = Vector2(cos(random_angle), sin(random_angle)) * spawn_radius
			var spawn_position = player.global_position + spawn_offset
	
			# 5. Position and spawn the enemy into the main world
			enemy_instance.global_position = spawn_position
			get_parent().add_child(enemy_instance)
			enemy_instance.add_to_group("enemies")

func _on_wave_timer_timeout() -> void:
	current_wave += 1
	print("Wave ", current_wave, " started!")
	emit_signal("wave_started", current_wave)
