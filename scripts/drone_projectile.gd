extends Area2D

var damage: float = 20.0
var speed: float = 200.0
var leaves_acid: bool = false
var is_explosive: bool = false
var pierce_count: int = 0
var hit_enemies: Array = []
var target: Node2D = null

func _ready():
	body_entered.connect(_on_body_entered)
	
	var t = Timer.new()
	t.wait_time = 5.0
	t.autostart = true
	t.one_shot = true
	t.timeout.connect(queue_free)
	add_child(t)

func _physics_process(delta):
	if not is_instance_valid(target):
		_find_target()
		
	if is_instance_valid(target):
		var dir = (target.global_position - global_position).normalized()
		position += dir * speed * delta
		rotation = dir.angle()
	else:
		position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _find_target():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var min_dist = INF
	for e in enemies:
		if is_instance_valid(e):
			var d = global_position.distance_to(e.global_position)
			if d < 400.0 and d < min_dist:
				min_dist = d
				target = e

func _on_body_entered(body):
	if body.has_method("take_damage") and not body in hit_enemies:
		body.take_damage(damage)
		hit_enemies.append(body)
		
		if pierce_count > 0:
			pierce_count -= 1
		else:
			_explode()

func _explode():
	if leaves_acid:
		var acid = preload("res://scenes/abilities/acid_pool.tscn").instantiate()
		acid.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", acid)
	if is_explosive:
		var boom = preload("res://scenes/explosion.tscn").instantiate()
		boom.global_position = global_position
		boom.damage = damage * 2.0
		get_tree().current_scene.call_deferred("add_child", boom)
	queue_free()
