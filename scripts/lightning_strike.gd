extends Node2D

@export var damage: float = 30.0
@export var cooldown: float = 3.0
@export var radius: float = 40.0
@export var chain_count: int = 0

var double_strike: bool = false
var has_knockback: bool = false
var is_overloaded: bool = false

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
	_execute_strike(target, valid)
	
	if double_strike:
		var valid_targets = valid.duplicate()
		valid_targets.erase(target)
		var target2 = target
		if valid_targets.size() > 0:
			target2 = valid_targets[randi() % valid_targets.size()]
			
		get_tree().create_timer(0.3).timeout.connect(func():
			var current_enemies = get_tree().get_nodes_in_group("enemies")
			var valid_now = []
			for e in current_enemies:
				if is_instance_valid(e): valid_now.append(e)
			if is_instance_valid(target2):
				_execute_strike(target2, valid_now)
		)

func _execute_strike(initial_target: Node2D, valid_enemies: Array):
	if not is_instance_valid(initial_target): return
	_strike(initial_target)
	
	var struck = [initial_target]
	for i in range(chain_count):
		var next_closest = null
		var min_d = INF
		for e in valid_enemies:
			if is_instance_valid(e) and not struck.has(e):
				var d = struck[-1].global_position.distance_to(e.global_position)
				if d < 150.0 and d < min_d:
					min_d = d
					next_closest = e
		if next_closest:
			get_tree().create_timer(0.1 * (i + 1)).timeout.connect(func(): if is_instance_valid(next_closest): _strike(next_closest))
			struck.append(next_closest)

func _strike(target: Node2D):
	var strike = preload("res://scenes/abilities/lightning_bolt.tscn").instantiate()
	strike.global_position = target.global_position
	strike.damage = damage
	strike.radius = radius * (1.5 if is_overloaded else 1.0)
	strike.has_knockback = has_knockback
	get_tree().current_scene.call_deferred("add_child", strike)
