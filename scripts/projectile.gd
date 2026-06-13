extends Area2D

@export var speed: float = 500
@export var damage: float = 1

# Holds a reference to the Node that fired this bullet (Player or Enemy)
var creator: Node = null 

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()

# Connect this from the Node tab -> Area2D signals -> body_entered(body: Node2D)
func _on_body_entered(body: Node2D) -> void:
	# Check if the object we hit has a method to take damage
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Delete the bullet upon impact
	queue_free()
	
	
	
