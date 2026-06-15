extends Node
func _ready() -> void:
	var player = get_parent()
	if player and "speed" in player:
		player.speed *= 1.2
