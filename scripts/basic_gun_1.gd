extends Node2D

@export var projectile_scene: PackedScene
@export var damage: float = 10.0
@export var target_layer: int = 3 # Layer 3 = Enemies, Layer 2 = Player
@export var projectile_speed: float = 500
@export var projectiles_per_shot: int = 1
@export var spread_angle_degrees: float = 0.0

var is_explosive: bool = false
var pierce_amount: int = 0
var fork_depth: int = 0
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
		var angles = []
		if projectiles_per_shot == 1:
			angles.append(0.0)
		else:
			var start_angle = -spread_angle_degrees / 2.0
			var step_angle = spread_angle_degrees / float(projectiles_per_shot - 1)
			for i in range(projectiles_per_shot):
				angles.append(start_angle + (step_angle * i))
		
		for angle_deg in angles:
			var bullet = projectile_scene.instantiate()
			bullet.speed = projectile_speed
			get_tree().current_scene.add_child(bullet)
			
			bullet.global_position = global_position
			bullet.global_rotation = global_rotation + deg_to_rad(angle_deg)
			
			bullet.creator = owner 
			bullet.damage = damage
			
			bullet.is_explosive = is_explosive
			bullet.pierce_remaining = pierce_amount
			bullet.fork_remaining = fork_depth
			
			bullet.collision_mask = 0
			bullet.set_collision_mask_value(target_layer, true)
		
