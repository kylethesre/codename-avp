extends Area2D

var damage: float = 10.0

func _ready() -> void:
	collision_mask = 0
	set_collision_mask_value(3, true) # Enemies are on Layer 3
	
	# Wait for physics engine to register overlaps
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for body in get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage)
			
	# Animate fade out
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.tween_callback(queue_free)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 60.0, Color(1.0, 0.5, 0.0, 0.5))
