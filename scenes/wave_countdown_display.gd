extends RichTextLabel
var the_time: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	the_time = get_tree().current_scene.find_child("WaveTimer", true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var current_time = the_time.time_left
	text = "Next in: %d" % current_time
