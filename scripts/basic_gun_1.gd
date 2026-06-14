extends Node2D

@export var projectile_scene: PackedScene
@export var damage: float = 10.0
@export var target_layer: int = 3 # Layer 3 = Enemies, Layer 2 = Player
@export var projectile_speed: float = 500
@onready var cooldown_timer: Timer = $Cooldown
@onready var radar: Area2D = $Radar

var current_target: Node2D = null

func _ready() -> void:
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	
	cooldown_timer.autostart = false
	cooldown_timer.stop()
	
	# Configure the radar to ONLY look for our designated targets
	radar.collision_mask = 0
	radar.set_collision_mask_value(target_layer, true)

func _physics_process(_delta: float) -> void:
	var targets = radar.get_overlapping_bodies()
	current_target = get_closest_target(targets)
	
	if current_target:
		# Rotate the entire component to face the target position
		look_at(current_target.global_position)
		
		if cooldown_timer.is_stopped():
			cooldown_timer.start()
			shoot() 
	else:
		if not cooldown_timer.is_stopped():
			cooldown_timer.stop()

func get_closest_target(targets: Array[Node2D]) -> Node2D:
	if targets.is_empty():
		return null
		
	var closest: Node2D = null
	var shortest_distance: float = INF 
	
	for target in targets:
		var distance = global_position.distance_to(target.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			closest = target
			
	return closest

func _on_cooldown_timer_timeout() -> void:
	shoot()

func shoot() -> void:
	if projectile_scene:
		var bullet = projectile_scene.instantiate()
		
		bullet.speed = projectile_speed
		
		get_tree().current_scene.add_child(bullet)
		
		# Spawn bullet at this component's exact position and rotation
		bullet.global_position = global_position
		bullet.global_rotation = global_rotation
		
		# Set bullet data properties
		bullet.creator = owner 
		bullet.damage = damage
		
		# Configure bullet collision filters
		bullet.collision_mask = 0
		bullet.set_collision_mask_value(target_layer, true)
		
