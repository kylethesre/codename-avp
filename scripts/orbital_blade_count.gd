extends Node
func _ready():
	var p = get_parent()
	if p:
		for c in p.get_children():
			if c.name == 'OrbitalBlades' or c.has_method('set_blade_count'):
				c.set_blade_count(c.blade_count + 1)
