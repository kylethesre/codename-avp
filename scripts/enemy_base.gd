extends CharacterBody2D

# 1. This creates a slot where you can drop a stat card
@export var stats: EnemyStats

# 2. Track the enemy's current health during gameplay
var current_health: float
var _max_health: float = 1.0

var player: Node2D = null

#Character knockback
var knockback_velocity = Vector2.ZERO
@export var friction = 500.0

var bleed_ticks_remaining: int = 0
var bleed_damage_per_tick: float = 0.0
var bleed_timer: Timer

var _cached_neighbors: Array = []
var _neighbor_refresh_timer: float = 0.0
const NEIGHBOR_REFRESH_INTERVAL: float = 0.25
const MIN_SEP_DIST: float = 24.0
const MIN_SEP_DIST_SQ: float = 576.0 # 24*24
const MAX_SEPARATION_NEIGHBORS: int = 6

var _spatial_grid: Node = null

var _ft_cooldown: float = 0.0
const FT_COOLDOWN_TIME: float = 0.2
const FloatingTextScene = preload("res://scenes/floating_text.tscn")

var _current_anim: String = ""
var _current_flip: bool = false

#Get reference for animated sprite
@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	# Add to enemies group for soft collision and player damage logic
	add_to_group("enemies")
	# Turn off hard physical collision with other enemies (Layer 3)
	set_collision_mask_value(3, false)
	
	# Initialize health using the resource data
	if stats:
		current_health = stats.max_health
		_max_health = stats.max_health
	else:
		push_error("Oops! This enemy doesn't have a stats resource assigned.")

	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
	
	# Find the spatial grid
	_spatial_grid = get_tree().current_scene.get_node_or_null("EnemySpatialGrid")
		
	bleed_timer = Timer.new()
	bleed_timer.wait_time = 0.5
	bleed_timer.timeout.connect(_on_bleed_tick)
	add_child(bleed_timer)
	
	# Stagger neighbor refresh so not all enemies refresh on the same frame
	_neighbor_refresh_timer = randf() * NEIGHBOR_REFRESH_INTERVAL

func _physics_process(_delta: float) -> void:
	if _ft_cooldown > 0:
		_ft_cooldown -= _delta
	
	#if knockback
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		move_and_slide()
		
		#reduce knockback over time
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, friction * _delta)
	#if no knockback
	elif player and stats:
		var direction = (player.global_position - global_position).normalized()
		
		# Calculate separation using spatial grid for fast neighbor lookup
		_neighbor_refresh_timer -= _delta
		if _neighbor_refresh_timer <= 0:
			_neighbor_refresh_timer = NEIGHBOR_REFRESH_INTERVAL
			if _spatial_grid:
				_cached_neighbors = _spatial_grid.get_nearby(global_position, self)
			else:
				_cached_neighbors = get_tree().get_nodes_in_group("enemies")
		
		var separation = Vector2.ZERO
		var sep_count = 0
		
		for neighbor in _cached_neighbors:
			if sep_count >= MAX_SEPARATION_NEIGHBORS:
				break
			if not is_instance_valid(neighbor):
				continue
			var diff = global_position - neighbor.global_position
			var dist_sq = diff.length_squared()
			if dist_sq > 0 and dist_sq < MIN_SEP_DIST_SQ:
				var dist = sqrt(dist_sq)
				separation += diff / dist * (1.0 - (dist / MIN_SEP_DIST))
				sep_count += 1
		
		var final_direction = (direction + separation * 1.5).normalized()
		
		velocity = final_direction * stats.speed
		move_and_slide()
		
	#Call animation after calculating velocity
	_update_animation()

func _draw() -> void:
	# Lightweight HP bar drawn directly - no Control node overhead
	if _max_health <= 0:
		return
	var hp_pct = clampf(current_health / _max_health, 0.0, 1.0)
	var bar_w = 24.0
	var bar_h = 3.0
	var bar_y = -20.0
	# Background
	draw_rect(Rect2(-bar_w * 0.5, bar_y, bar_w, bar_h), Color(0.2, 0.2, 0.2, 0.8))
	# Fill
	if hp_pct > 0:
		draw_rect(Rect2(-bar_w * 0.5, bar_y, bar_w * hp_pct, bar_h), Color(0.8, 0.1, 0.1, 0.8))

func _update_animation() -> void:
	if velocity.length_squared() > 0:
		if _current_anim != "walk_side":
			_current_anim = "walk_side"
			animated_sprite.play("walk_side")
		
		#Flip sprite horizontally based on movement direction
		var should_flip = velocity.x < 0
		if should_flip != _current_flip:
			_current_flip = should_flip
			animated_sprite.flip_h = should_flip
	else:
		if _current_anim != "idle":
			_current_anim = "idle"
			animated_sprite.stop()
		
func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force

## A quick function showing how armor and health interact
func take_damage(amount: float) -> void:
	if not stats: return
	
	# Simple math: reduce damage taken by the armor amount (minimum 1 damage)
	var final_damage = max(amount - stats.armor, 1.0)
	current_health -= final_damage
	
	# Redraw HP bar
	queue_redraw()
		
	# Damage indicator - throttled to prevent node spam
	if _ft_cooldown <= 0:
		_ft_cooldown = FT_COOLDOWN_TIME
		var ft = FloatingTextScene.instantiate()
		var lbl = ft.get_node("Label")
		lbl.text = str(int(final_damage))
		lbl.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		lbl.add_theme_font_size_override("font_size", 10)
		
		ft.global_position = global_position + Vector2(randf_range(-10, 10), -20)
		get_tree().current_scene.call_deferred("add_child", ft)
	
	if current_health <= 0:
		if player and player.has_signal("enemy_killed"):
			player.enemy_killed.emit()
		queue_free() # Enemy dies!

func apply_bleed(duration: float, damage_per_tick: float) -> void:
	# Tick every 0.5s
	bleed_ticks_remaining = int(duration / 0.5)
	bleed_damage_per_tick = damage_per_tick
	if bleed_timer.is_stopped():
		bleed_timer.start()

func _on_bleed_tick() -> void:
	if bleed_ticks_remaining > 0:
		take_damage(bleed_damage_per_tick)
		bleed_ticks_remaining -= 1
		# Visual flash
		animated_sprite.modulate = Color(1.0, 0.5, 0.5)
		var tw = create_tween()
		tw.tween_property(animated_sprite, "modulate", Color.WHITE, 0.2)
	else:
		bleed_timer.stop()
