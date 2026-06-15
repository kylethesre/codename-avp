extends Node2D
var damage = 30.0
var radius = 40.0

func _ready():
	var area = Area2D.new()
	area.collision_mask = 0
	area.set_collision_mask_value(3, true)
	var shape = CollisionShape2D.new()
	var circ = CircleShape2D.new()
	circ.radius = radius
	shape.shape = circ
	area.add_child(shape)
	add_child(area)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for body in area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage)
			
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.3)
	tw.tween_callback(queue_free)

func _draw():
	var c = Color(1.0, 1.0, 0.2, 0.8)
	draw_line(Vector2(0, -300), Vector2(0, 0), Color.WHITE, 6.0)
	draw_line(Vector2(-5, -300), Vector2(-5, 0), c, 2.0)
	draw_line(Vector2(5, -300), Vector2(5, 0), c, 2.0)
	draw_circle(Vector2(0, 0), radius, Color(1.0, 1.0, 0.0, 0.4))
