extends Node
func _ready():
	var p = get_parent()
	if p:
		for c in p.get_children():
			if c.name == 'OrbitalBlades' or c.has_method("set_speed"):
				c.set_speed(c.speed + 3.0)
