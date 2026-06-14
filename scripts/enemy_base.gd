extends CharacterBody2D

# 1. This creates a slot where you can drop a stat card
@export var stats: EnemyStats

# 2. Track the enemy's current health during gameplay
var current_health: float

var player: Node2D = null

#Character knockback
var knockback_velocity = Vector2.ZERO
@export var friction = 500.0


func _ready() -> void:
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
		
		# 3. Use the speed value stored inside our resource!
		velocity = direction * stats.speed
		move_and_slide()
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
