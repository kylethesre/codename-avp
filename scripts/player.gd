extends CharacterBody2D
class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var health: int = 4
@export var max_health: int = 4

signal health_changed(health: int, max_health: int)

func _ready() -> void:
	health_changed.emit(health, max_health)

func _input(event: InputEvent) -> void:
	if event.get_action_strength("ui_accept"):
		health -= 1
		health_changed.emit(health, max_health)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_vector := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	var normalized_direction := direction_vector.normalized()
	
	if direction_vector.length_squared() > 0.5:
		velocity.x = normalized_direction.x * SPEED
		velocity.y = normalized_direction.y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()


#Knockback enemies in a circle radius automatically when anything enters area
#func _on_knockback_area_body_entered(body: Node2D) -> void:
#	print("something entered the area: ", body) #debug check
#	print(get_tree().get_nodes_in_group("enemies"))
	#direction
#	if body.is_in_group("enemies"):
#		for enemy in get_tree().get_nodes_in_group("enemies"):
#			print("enemy detected! sending knockback signal.") # 2nd debug check
#			var direction = (enemy.global_position - global_position).normalized()
			
#			if enemy.has_method("apply_knockback"):
#				enemy.apply_knockback(direction * 300.0)



	
func trigger_radial_knockback():
	var pulse_radius = 75.0
	var max_knockback_force = 800.0
	
	# 1. Get every enemy in the entire game world
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	
	# 2. Loop through every single one
	for enemy in all_enemies:
		# Check distance between Player and THIS specific enemy
		var distance = global_position.distance_to(enemy.global_position)
		
		# 3. Only apply logic if they are within our radius
		if distance <= pulse_radius:
			
			# Calculate falloff (closer = more power, further = less power)
			var strength = clamp(1.0 - (distance / pulse_radius), 0.0, 1.0)
			var final_force = max_knockback_force * strength
			
			# 4. Apply the knockback
			if enemy.has_method("apply_knockback"):
				var direction = (enemy.global_position - global_position).normalized()
				enemy.apply_knockback(direction * final_force)
				
func _on_knockback_area_body_entered(body: Node2D) -> void:
	print("something entered the area: ", body) #debug check
	print(get_tree().get_nodes_in_group("enemies"))
	#direction
	if body.is_in_group("enemies"):
		if $Timer.is_stopped():
			trigger_radial_knockback()
			$Timer.start()
