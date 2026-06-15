extends Node
func _ready():
	var p = get_parent()
	if p:
		for c in p.get_children():
			if c.name == 'Scratch' or "cooldown" in c:
				c.cooldown *= 0.5
				if c.has_node("Timer"):
					c.get_node("Timer").wait_time = c.cooldown
