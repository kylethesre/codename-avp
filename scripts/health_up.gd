extends Node

func _ready() -> void:
	# The UpgradeManager adds this ability directly as a child of the player
	var player = get_parent()
	if player and player.has_method("take_damage"):
		# Assuming the player script has max_health and health properties (which it does)
		player.max_health += 1
		player.health += 1
		
		# Emit the signal so the HUD updates
		player.health_changed.emit(player.health, player.max_health)
