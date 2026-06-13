extends CharacterBody2D

# 1. This creates a slot where you can drop a stat card
@export var stats: EnemyStats

# 2. Track the enemy's current health during gameplay
var current_health: float

var player: Node2D = null

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
	if player and stats:
		var direction = (player.global_position - global_position).normalized()
		
		# 3. Use the speed value stored inside our resource!
		velocity = direction * stats.speed
		move_and_slide()

## A quick function showing how armor and health interact
func take_damage(amount: float) -> void:
	if not stats: return
	
	# Simple math: reduce damage taken by the armor amount (minimum 1 damage)
	var final_damage = max(amount - stats.armor, 1.0)
	current_health -= final_damage
	
	print(name, " took ", final_damage, " damage. Health remaining: ", current_health)
	
	if current_health <= 0:
		queue_free() # Enemy dies!
