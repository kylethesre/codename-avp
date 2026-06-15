extends CharacterBody2D
class_name Player

var speed = 200.0
var knockback_velocity = Vector2.ZERO
var dodge_chance: float = 0.0
var health: int = 4
@export var max_health: int = 4

var is_dashing: bool = false
var is_invincible: bool = false
var dash_cooldown: float = 0.0
var dash_speed: float = 600.0

signal health_changed(health: int, max_health: int)
signal enemy_killed

# Node references
@onready var animated_sprite = $AnimatedSprite2D
@onready var effect_sprite = $EffectSprite
var is_hurt: bool = false
const FloatingTextScene = preload("res://scenes/floating_text.tscn")

func take_damage(amount: int = 1, source_pos: Vector2 = Vector2.ZERO):
	if is_invincible:
		return
		
	if randf() < dodge_chance:
		# Dodge successful!
		var ft = FloatingTextScene.instantiate()
		ft.global_position = global_position + Vector2(0, -20)
		get_tree().current_scene.add_child(ft)
		
		# Still do knockback even if dodged
		trigger_radial_knockback()
		if source_pos != Vector2.ZERO:
			knockback_velocity = (global_position - source_pos).normalized() * 100
		return
	health -= amount
	health_changed.emit(health, max_health)
	#added for hurt animation
	is_hurt = true
	effect_sprite.show()
	animated_sprite.play("Hurt")
	effect_sprite.play("HitSpark")
	await get_tree().create_timer(0.3).timeout # Adjust 0.3 to your animation length
	is_hurt = false
	
	# Knockback always happens on damage
	trigger_radial_knockback()
	if source_pos != Vector2.ZERO:
		knockback_velocity = (global_position - source_pos).normalized() * 100
	
	# --- ADDED LOGIC START ---
	if health <= 0:
		health = 0
		trigger_game_over()
	# --- ADDED LOGIC END ---

# --- ADDED FUNCTION AT THE BOTTOM ---
func trigger_game_over():
	var game_over_screen = get_tree().current_scene.get_node_or_null("GameOverMenu")
	if game_over_screen:
		game_over_screen.show_game_over()
	else:
		print("Error: GameOverMenu node not found in current scene!")
# ------------------------------------

func _ready() -> void:
	health_changed.emit(health, max_health)

func _input(event: InputEvent) -> void:
	pass

func _physics_process(delta: float) -> void:
	
	
	# Get the input direction and handle the movement/deceleration. WASD code in comments below if needed.
	#var direction_vector := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	
	
	# Get the input direction and handle the movement
	var direction_vector := Vector2(
		Input.get_axis("move_left", "move_right"), 
		Input.get_axis("move_up", "move_down")
	)
	
	var normalized_direction := direction_vector.normalized()
	
	if dash_cooldown > 0:
		dash_cooldown -= delta
		
	if Input.is_action_just_pressed("ui_accept") and dash_cooldown <= 0 and direction_vector.length() > 0:
		start_dash(normalized_direction)
		
	if is_dashing:
		move_and_slide()
		return
	
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500 * delta)
	
	var movement_velocity = Vector2.ZERO
	
	if direction_vector.length_squared() > 0.5:
		movement_velocity = normalized_direction * speed
		
		if movement_velocity.x != 0:
			animated_sprite.flip_h = movement_velocity.x < 0
		
		velocity = movement_velocity + knockback_velocity
	else:
		velocity = velocity.move_toward(knockback_velocity, speed)
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("enemies"):
			if $Timer.is_stopped():
				take_damage(1, collision.get_collider().global_position)
				$Timer.start()

func start_dash(dir: Vector2) -> void:
	is_dashing = true
	is_invincible = true
	dash_cooldown = 2.0
	
	# Knockback nearby enemies when starting the dash
	trigger_radial_knockback()
	
	velocity = dir * dash_speed
	
	await get_tree().create_timer(0.2).timeout
	is_dashing = false
	velocity = Vector2.ZERO
	
	# Give a tiny bit of lingering i-frames after the dash ends
	await get_tree().create_timer(0.1).timeout
	is_invincible = false

#Knockback feature
func trigger_radial_knockback():

	var pulse_radius = 75.0
	# Set a reasonable max force to prevent launching
	var max_knockback_force = 300.0 
	
	#Get every enemy in the entire game world
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	
	#Loop through every single one
	for enemy in all_enemies:
		# Check distance between Player and THIS specific enemy
		var distance = global_position.distance_to(enemy.global_position)
		
		#Only apply logic if they are within player radius
		if distance <= pulse_radius:
			
			#Calculate falloff (closer = more power, further = less power)
			var linear_strength = clamp(1.0 - (distance / pulse_radius), 0.0, 1.0)
			
			# Flatten the curve significantly: 
			# Enemies right next to you get 100% force, enemies at the edge get 50% force.
			# This ensures a much more uniform push and stops close enemies from flying away
			var strength = lerp(0.5, 1.0, linear_strength)
			
			var final_force = max_knockback_force * strength
			
			# 4. Apply the knockback
			if enemy.has_method("apply_knockback"):
				var direction = (enemy.global_position - global_position).normalized()
				enemy.apply_knockback(direction * final_force)

#Animation process to make the sprites flip
func _process(_delta):
	# 1. If we are hurt, stop everything else and just exit the function
	if is_hurt:
		return 
	
	# 2. Only if we are NOT hurt, do the movement animations
	if velocity.length() > 0:
		animated_sprite.play("Run")
	else:
		animated_sprite.play("Idle")
		
