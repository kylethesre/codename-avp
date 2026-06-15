extends Node
func _ready() -> void:
	var player = get_parent()
	if not player: return
	for child in player.get_children():
		if child.has_method("shoot"):
			child.is_explosive = true
