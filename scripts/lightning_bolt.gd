extends Area2D
var damage = 30.0
var radius = 40.0
var has_knockback = false

func _ready():
	var shape = CircleShape2D.new()
	shape.radius = radius
	var collision = CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for body in get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage)
			if has_knockback and body.has_method("apply_knockback"):
				var dir = (body.global_position - global_position).normalized()
				body.apply_knockback(dir * 300.0)
			
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.3)
	tw.tween_callback(queue_free)
