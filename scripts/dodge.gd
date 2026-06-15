extends Node
func _ready() -> void:
	var player = get_parent()
	if player and "dodge_chance" in player:
		player.dodge_chance += 0.10
