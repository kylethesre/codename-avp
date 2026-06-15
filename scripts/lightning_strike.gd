extends Node2D

@export var damage: float = 30.0
@export var cooldown: float = 3.0
@export var radius: float = 40.0
@export var chain_count: int = 0

@onready var timer = $Timer

func _ready():
	timer.wait_time = cooldown
	timer.timeout.connect(_on_timeout)
	timer.start()

func _on_timeout():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty(): return
	
	var valid = []
	for e in enemies:
		if is_instance_valid(e): valid.append(e)
	if valid.is_empty(): return
	
	var target = valid[randi() % valid.size()]
	_strike(target)
	
	var struck = [target]
	
	for i in range(chain_count):
		var next_closest = null
		var min_d = INF
		for e in valid:
			if not struck.has(e):
				var d = struck[-1].global_position.distance_to(e.global_position)
				if d < 150.0 and d < min_d:
					min_d = d
					next_closest = e
		if next_closest:
			_strike(next_closest)
			struck.append(next_closest)

func _strike(target: Node2D):
	var strike = preload("res://scenes/abilities/lightning_bolt.tscn").instantiate()
	strike.global_position = target.global_position
	strike.damage = damage
	strike.radius = radius
	get_tree().current_scene.call_deferred("add_child", strike)
