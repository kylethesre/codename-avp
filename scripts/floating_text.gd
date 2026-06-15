extends Node2D

func _ready() -> void:
	# Animate float up and fade out over 1 second
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 40, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# After parallel animations finish, delete the node
	tween.chain().tween_callback(queue_free)
