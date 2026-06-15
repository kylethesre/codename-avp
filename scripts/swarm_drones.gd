extends Node2D

@export var drone_count: int = 1
@export var cooldown: float = 4.0
@export var drone_speed: float = 200.0
@export var damage: float = 20.0
@export var leaves_acid: bool = false
@export var is_explosive: bool = false
@export var pierce_count: int = 0

@onready var timer = $Timer

func _ready():
	timer.wait_time = cooldown
	timer.timeout.connect(_on_timeout)
	timer.start()

func _on_timeout():
	for i in range(drone_count):
		var drone = preload("res://scenes/abilities/drone_projectile.tscn").instantiate()
		drone.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		drone.damage = damage
		drone.speed = drone_speed
		drone.leaves_acid = leaves_acid
		drone.is_explosive = is_explosive
		drone.pierce_count = pierce_count
		get_tree().current_scene.call_deferred("add_child", drone)
