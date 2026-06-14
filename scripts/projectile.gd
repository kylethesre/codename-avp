extends Area2D

@export var speed: float = 500
@export var damage: float = 1

#Holds a reference to the Node that fired this bullet
var creator: Node = null

#Grab the sound node right below your variables
@onready var ability_sound = $AbilitySound

#Add _ready function to play it immediately
func _ready() -> void:
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
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Check if the object we hit has a method to take damage
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Delete the bullet upon impact
	queue_free()
