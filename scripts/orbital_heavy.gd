extends Node
func _ready():
	var p = get_parent()
	if p:
		for c in p.get_children():
			if c.name == 'OrbitalBlades' or "heavy_blades" in c:
				c.heavy_blades = true
