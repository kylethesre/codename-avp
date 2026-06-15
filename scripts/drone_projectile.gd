extends Area2D

var damage: float = 20.0
var speed: float = 200.0
var leaves_acid: bool = false
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
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
