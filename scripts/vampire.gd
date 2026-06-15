extends Node

var level: int = 1

func _ready() -> void:
	var player = get_parent()
	if not player: return
	
	# Find if another Vampire node already exists on the player
	for child in player.get_children():
		if child != self and child.get_script() == get_script() and not child.is_queued_for_deletion():
			# Another one exists! Increment its level and delete ourselves
			child.level += 1
			queue_free()
			return
			
	# If we are the first one, setup the signal
	if player.has_signal("enemy_killed"):
		player.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed() -> void:
	# Exact N% chance (e.g. level 5 = 5% chance) to heal exactly once
	var chance = float(level) / 100.0
	if randf() <= chance:
		var player = get_parent()
		# Heal if not at max health
		if player.health < player.max_health:
			player.health += 1
			player.health_changed.emit(player.health, player.max_health)
