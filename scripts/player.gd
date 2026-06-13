extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


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
