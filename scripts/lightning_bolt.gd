extends Area2D
var damage = 30.0
var radius = 40.0

func _ready():
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for body in get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage)
			
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.3)
	tw.tween_callback(queue_free)
