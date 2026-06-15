extends Area2D

var damage: float = 20.0
var speed: float = 200.0
var leaves_acid: bool = false
var target: Node2D = null

func _ready():
	collision_mask = 0
	set_collision_mask_value(3, true)
	body_entered.connect(_on_body_entered)
	
	var shape = CollisionShape2D.new()
	var circ = CircleShape2D.new()
	circ.radius = 8.0
	shape.shape = circ
	add_child(shape)
	
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

func _draw():
	var c = Color(0.2, 1.0, 0.2, 0.8)
	draw_circle(Vector2.ZERO, 6.0, c)
	draw_line(Vector2(0, -6), Vector2(10, 0), c, 2.0)
	draw_line(Vector2(0, 6), Vector2(10, 0), c, 2.0)
