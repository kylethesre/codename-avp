extends CharacterBody2D
class_name Player

const SPEED = 300.0

var knockback_velocity = Vector2.ZERO

var health: int = 4
@export var max_health: int = 4

signal health_changed(health: int, max_health: int)

# --- WE MOVED THIS HERE ---
# It is best practice to keep your node references at the top!
@onready var animated_sprite = $AnimatedSprite2D

func take_damage(amount: int = 1):
	health -= amount
	health_changed.emit(health, max_health)

func _ready() -> void:
	health_changed.emit(health, max_health)

func _input(event: InputEvent) -> void:
	if event.get_action_strength("ui_accept"):
		health -= 1
		health_changed.emit(health, max_health)

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction_vector := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
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
	#If the character's velocity is greater than 0, they are moving.
	if velocity.length() > 0:
		animated_sprite.play("Run")
			
	#If the velocity is exactly 0, they are standing still.
	else:
		animated_sprite.play("Idle")
