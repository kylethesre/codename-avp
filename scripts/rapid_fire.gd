extends Node
func _ready() -> void:
	var player = get_parent()
	if not player: return
	for child in player.get_children():
		if child.has_method("shoot"):
			var cd = child.get_node_or_null("Cooldown")
			if cd:
				cd.wait_time *= 0.7
