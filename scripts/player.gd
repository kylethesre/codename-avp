extends CharacterBody2D
class_name Player

const SPEED = 200.0
var knockback_velocity = Vector2.ZERO
var health: int = 4
@export var max_health: int = 4

signal health_changed(health: int, max_health: int)

# Node references
@onready var animated_sprite = $AnimatedSprite2D

var is_hurt: bool = false

func take_damage(amount: int = 1):
	health -= amount
	health_changed.emit(health, max_health)
	#added for hurt animation
	is_hurt = true
	animated_sprite.play("Hurt")
	await get_tree().create_timer(0.3).timeout # Adjust 0.3 to your animation length
	is_hurt = false
	
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
	if event.get_action_strength("ui_accept"):
		health -= 1
		health_changed.emit(health, max_health)

func _physics_process(delta: float) -> void:
	
	
	# Get the input direction and handle the movement/deceleration. WASD code in comments below if needed.
	#var direction_vector := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	
	
	# Get the input direction and handle the movement
	var direction_vector := Vector2(
		Input.get_axis("move_left", "move_right"), 
		Input.get_axis("move_up", "move_down")
	)
	
	var normalized_direction := direction_vector.normalized()
	
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500 * delta)
	
	var movement_velocity = Vector2.ZERO
	
	if direction_vector.length_squared() > 0.5:
		movement_velocity = normalized_direction * SPEED
		
		if movement_velocity.x != 0:
			animated_sprite.flip_h = movement_velocity.x < 0
		
		velocity = movement_velocity + knockback_velocity
	else:
		velocity = velocity.move_toward(knockback_velocity, SPEED)
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("enemies"):
			if $Timer.is_stopped():
				trigger_radial_knockback()
				knockback_velocity = (global_position - collision.get_collider().global_position).normalized() * 100
				take_damage()
				$Timer.start()

#Knockback feature
func trigger_radial_knockback():

	var pulse_radius = 75.0
	var max_knockback_force = 800.0
	
	#Get every enemy in the entire game world
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	
	#Loop through every single one
	for enemy in all_enemies:
		# Check distance between Player and THIS specific enemy
		var distance = global_position.distance_to(enemy.global_position)
		
		#Only apply logic if they are within player radius
		if distance <= pulse_radius:
			
			#Calculate falloff (closer = more power, further = less power)
			var strength = clamp(1.0 - (distance / pulse_radius), 0.0, 1.0)
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
		
		# If we are hurt, we do NOT run the movement animation logic
	if is_hurt:
		return 

	# Existing logic remains
	if velocity.length() > 0:
		animated_sprite.play("Run")
	else:
		animated_sprite.play("Idle")
