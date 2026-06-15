extends Node2D

@export var damage: float = 10.0
@export var speed: float = 3.0
@export var radius: float = 60.0
@export var blade_count: int = 2

var blades: Array = []
var hit_cooldowns = {} 

func _ready():
	_update_blades()

func set_blade_count(v: int):
	blade_count = v
	if is_inside_tree():
		_update_blades()
		
func set_radius(v: float):
	radius = v
	
func set_speed(v: float):
	speed = v

func _update_blades():
	for b in blades:
		if is_instance_valid(b):
			b.queue_free()
	blades.clear()
	
	for i in range(blade_count):
		var area = Area2D.new()
		area.collision_mask = 0
		area.set_collision_mask_value(3, true)
		
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 12.0
		shape.shape = circle
		area.add_child(shape)
		
		add_child(area)
		blades.append(area)

func _physics_process(delta):
	rotation += speed * delta
	var angle_step = PI * 2.0 / blade_count
	
	var keys = hit_cooldowns.keys()
	for key in keys:
		hit_cooldowns[key] -= delta
		if hit_cooldowns[key] <= 0:
			hit_cooldowns.erase(key)
			
	for i in range(blade_count):
		if not is_instance_valid(blades[i]): continue
		var angle = i * angle_step
		blades[i].position = Vector2(cos(angle), sin(angle)) * radius
		
		for body in blades[i].get_overlapping_bodies():
			if not hit_cooldowns.has(body):
				if body.has_method("take_damage"):
					body.take_damage(damage)
					hit_cooldowns[body] = 0.5 
	queue_redraw()

func _draw():
	var angle_step = PI * 2.0 / blade_count
	for i in range(blade_count):
		var angle = i * angle_step
		var pos = Vector2(cos(angle), sin(angle)) * radius
		draw_circle(pos, 12.0, Color(0, 1, 1, 0.8)) # Aqua
		draw_circle(pos, 6.0, Color.WHITE)
