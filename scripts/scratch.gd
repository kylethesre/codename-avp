extends Node2D

@export var damage: float = 15.0
@export var cooldown: float = 1.5
@export var range_dist: float = 100.0

@onready var timer = $Timer
@onready var hit_area = $HitArea
@onready var sprite = $HitArea/Sprite2D

func _ready():
	timer.wait_time = cooldown
	timer.timeout.connect(_on_timeout)
	timer.start()
	hit_area.monitoring = false
	sprite.visible = false

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
		sprite.visible = true
		sprite.scale = Vector2(0.5, 0.5)
		sprite.modulate.a = 1.0
		hit_area.monitoring = true
		
		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.1)
		tw.tween_property(sprite, "modulate:a", 0.0, 0.2)
		
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		for body in hit_area.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(damage)
				if body.has_method("apply_knockback"):
					body.apply_knockback((body.global_position - global_position).normalized() * 200)
				
		hit_area.monitoring = false
		await tw.finished
		sprite.visible = false
