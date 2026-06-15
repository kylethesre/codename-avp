extends Node2D

@export var damage: float = 15.0
@export var cooldown: float = 1.5
@export var range_dist: float = 100.0

@onready var timer = $Timer
@onready var hit_area = $HitArea

var is_scratching: bool = false
var scratch_alpha: float = 0.0

func _ready():
	timer.wait_time = cooldown
	timer.timeout.connect(_on_timeout)
	timer.start()
	hit_area.monitoring = false
	hit_area.collision_mask = 0
	hit_area.set_collision_mask_value(3, true) # Layer 3 = Enemies

func _on_timeout():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest = null
	var min_dist = INF
	for e in enemies:
		if not is_instance_valid(e): continue
		var d = global_position.distance_to(e.global_position)
		if d < range_dist and d < min_dist:
			min_dist = d
			closest = e
			
	if closest:
		look_at(closest.global_position)
		is_scratching = true
		scratch_alpha = 1.0
		hit_area.monitoring = true
		queue_redraw()
		
		# Animate the scratch fading
		var tw = create_tween()
		tw.tween_property(self, "scratch_alpha", 0.0, 0.2)
		
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		for body in hit_area.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(damage)
				if body.has_method("apply_knockback"):
					body.apply_knockback((body.global_position - global_position).normalized() * 200)
				
		hit_area.monitoring = false
		await tw.finished
		is_scratching = false
		queue_redraw()

func _draw():
	if is_scratching:
		var c = Color(1.0, 0.1, 0.1, scratch_alpha)
		# Draw 3 claw marks
		draw_line(Vector2(20, -15), Vector2(60, -15), c, 4.0)
		draw_line(Vector2(20, 0), Vector2(65, 0), c, 4.0)
		draw_line(Vector2(20, 15), Vector2(60, 15), c, 4.0)
