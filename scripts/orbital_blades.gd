extends Node2D

@export var damage: float = 10.0
@export var speed: float = 3.0
@export var radius: float = 60.0
@export var blade_count: int = 2

var heavy_blades: bool = false
var blades: Array = []
var hit_cooldowns = {}
var knockback_cooldown: float = 0.0 

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
	
	var blade_scene = preload("res://scenes/abilities/orbital_blade_projectile.tscn")
	for i in range(blade_count):
		var area = blade_scene.instantiate()
		add_child(area)
		blades.append(area)

func _physics_process(delta):
	rotation += speed * delta
	var angle_step = PI * 2.0 / blade_count
	
	if knockback_cooldown > 0:
		knockback_cooldown -= delta
		
	var keys = hit_cooldowns.keys()
	for key in keys:
		hit_cooldowns[key] -= delta
		if hit_cooldowns[key] <= 0:
			hit_cooldowns.erase(key)
			
	for i in range(blade_count):
		if not is_instance_valid(blades[i]): continue
		var angle = i * angle_step
		blades[i].position = Vector2(cos(angle), sin(angle)) * radius
		blades[i].rotation = angle + (PI / 2.0)
		
		for body in blades[i].get_overlapping_bodies():
			if not hit_cooldowns.has(body):
				if body.has_method("take_damage"):
					body.take_damage(damage)
					hit_cooldowns[body] = 0.5
					if heavy_blades and knockback_cooldown <= 0:
						knockback_cooldown = 2.0
						for e in get_tree().get_nodes_in_group("enemies"):
							if is_instance_valid(e) and e.has_method("apply_knockback"):
								var dist = e.global_position.distance_to(blades[i].global_position)
								if dist < 150.0:
									var push_dir = (e.global_position - global_position).normalized()
									var push_strength = 500.0 * (1.0 - (dist / 150.0))
									e.apply_knockback(push_dir * push_strength)
									
		for area in blades[i].get_overlapping_areas():
			if not hit_cooldowns.has(area):
				if area.is_in_group("projectiles"):
					hit_cooldowns[area] = 0.5
					var away_dir = (area.global_position - global_position).normalized()
					# randfn(mean, std_dev) creates a bell curve centered at 0 (away)
					# with PI/1.8, most shots go away, but ~15-20% will deflect backwards towards the player
					var random_angle = randfn(0.0, PI / 1.8)
					area.rotation = away_dir.angle() + random_angle
