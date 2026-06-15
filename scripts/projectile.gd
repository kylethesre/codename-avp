extends Area2D

#Holds a reference to the Node that fired this bullet
var creator: Node2D = null
var damage: float = 10.0
var speed: float = 400.0

var is_explosive: bool = false
var explosion_damage: float = 15.0
var pierce_remaining: int = 0
var fork_remaining: int = 0
var hit_targets: Array[Node2D] = []

const ExplosionScene = preload("res://scenes/explosion.tscn")

#Grab the sound node right below your variables
@onready var ability_sound = $AbilitySound

#Add _ready function to play it immediately
func _ready() -> void:
	add_to_group("projectiles")
	get_tree().create_timer(5.0).timeout.connect(queue_free)
	
	# Create a temporary AudioStreamPlayer2D
	var temp_audio = AudioStreamPlayer2D.new()
	temp_audio.stream = ability_sound.stream # Copy the sound file
	temp_audio.bus = "SFX" # Make sure it uses your SFX bus!
	add_child(temp_audio) # Add it to the bullet
	
	temp_audio.play()
	
	#Automatically delete this temporary player when the sound finishes
	temp_audio.finished.connect(temp_audio.queue_free)

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	pass # Disabled so projectiles can wrap around the screen

func _on_body_entered(body: Node2D) -> void:
	if body in hit_targets: return
	
	# Check if the object we hit has a method to take damage
	if body.has_method("take_damage"):
		hit_targets.append(body)
		body.take_damage(damage)
		
		if pierce_remaining > 0:
			pierce_remaining -= 1
		else:
			if is_explosive:
				var expl = ExplosionScene.instantiate()
				expl.global_position = global_position
				expl.damage = explosion_damage
				get_tree().current_scene.call_deferred("add_child", expl)
				
			if fork_remaining > 0:
				fork_remaining -= 1
				for angle in [-15, 15]:
					var new_bullet = load(scene_file_path).instantiate()
					new_bullet.global_position = global_position
					new_bullet.global_rotation = global_rotation + deg_to_rad(angle)
					new_bullet.damage = damage / 2.0
					new_bullet.speed = speed
					new_bullet.creator = creator
					new_bullet.collision_mask = collision_mask
					new_bullet.is_explosive = is_explosive
					new_bullet.explosion_damage = explosion_damage / 2.0
					new_bullet.pierce_remaining = pierce_remaining
					new_bullet.fork_remaining = fork_remaining
					new_bullet.hit_targets = hit_targets.duplicate()
					get_tree().current_scene.call_deferred("add_child", new_bullet)
				queue_free()
			else:
				queue_free()
