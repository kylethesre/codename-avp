extends Node
func _ready() -> void:
	var player = get_parent()
	if not player: return
	for child in player.get_children():
		if child.has_method("shoot"):
			child.projectiles_per_shot = 2
			child.spread_angle_degrees = 15.0
