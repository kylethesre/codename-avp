extends CharacterBody2D

# 1. This creates a slot where you can drop a stat card
@export var stats: EnemyStats

# 2. Track the enemy's current health during gameplay
var current_health: float

var player: Node2D = null

#Character knockback
var knockback_velocity = Vector2.ZERO
@export var friction = 500.0

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
	else:
		push_error("Oops! This enemy doesn't have a stats resource assigned.")

	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func _physics_process(_delta: float) -> void:
	#if knockback
	
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		move_and_slide()
		
		#reduce knockback over time
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, friction * _delta)
	#if no knockback
	elif player and stats:
		var direction = (player.global_position - global_position).normalized()
		
		# Calculate separation to avoid overlapping other enemies
		var separation = Vector2.ZERO
		var neighbors = get_tree().get_nodes_in_group("enemies")
		var min_separation_dist = 24.0 # Adjust based on enemy sprite size
		
		for neighbor in neighbors:
			if neighbor == self or not is_instance_valid(neighbor):
				continue
			var diff = global_position - neighbor.global_position
			var dist = diff.length()
			if dist > 0 and dist < min_separation_dist:
				# Push away strongly the closer they are
				separation += diff.normalized() * (1.0 - (dist / min_separation_dist))
		
		var final_direction = (direction + separation * 1.5).normalized()
		
		# 3. Use the speed value stored inside our resource!
		velocity = final_direction * stats.speed
		move_and_slide()
		
	#Call animation after calculating velocity	
	update_animation()
	
	#Animated sprite flip code
func update_animation() -> void:
	#Check if the enemy is actually moving
	if velocity.length() > 0:
		#Play the walking animation
		animated_sprite.play("walk_side")
		
		#Flip sprite horizontally if moving left (negative x velocity)
		if velocity.x < 0:
			animated_sprite.flip_h = true
		#Un-flip the sprite if moving right (positive x velocity)
		elif velocity.x > 0:
			animated_sprite.flip_h = false
	else:
		#Stop the animation (or play an "idle" animation) if standing still
		animated_sprite.stop()
		
			
		#more knockback stuff
func apply_knockback(force: Vector2) -> void:
	print("Enemy ", name, " received knockback force: ", force) # Now this will work!
	knockback_velocity = force

## A quick function showing how armor and health interact
func take_damage(amount: float) -> void:
	if not stats: return
	
	# Simple math: reduce damage taken by the armor amount (minimum 1 damage)
	var final_damage = max(amount - stats.armor, 1.0)
	current_health -= final_damage
	
	print(name, " took ", final_damage, " damage. Health remaining: ", current_health)
	
	if current_health <= 0:
		queue_free() # Enemy dies!
