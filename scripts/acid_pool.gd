extends Area2D

var damage_per_tick: float = 5.0
var duration: float = 3.0
var radius: float = 50.0
var enemies_inside: Array[Node2D] = []

func _ready() -> void:
	collision_mask = 0
	set_collision_mask_value(3, true) # Enemies are on layer 3
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	var tick_timer = Timer.new()
	tick_timer.wait_time = 0.5
	tick_timer.autostart = true
	tick_timer.timeout.connect(_on_tick)
	add_child(tick_timer)
	
	var duration_timer = Timer.new()
	duration_timer.wait_time = duration
	duration_timer.one_shot = true
	duration_timer.autostart = true
	duration_timer.timeout.connect(queue_free)
	add_child(duration_timer)
	
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		enemies_inside.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body in enemies_inside:
		enemies_inside.erase(body)

func _on_tick() -> void:
	for enemy in enemies_inside:
		if is_instance_valid(enemy):
			enemy.take_damage(damage_per_tick)

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(0.0, 1.0, 0.0, 0.4))
